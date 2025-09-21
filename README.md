# Terraform AWS (S3+DynamoDB backend, VPC, ECR, EKS) + Helm (Django)

## Структура

```
lesson-7/
  main.tf
  backend.tf
  variables.tf
  outputs.tf
	dev.tfvars
  modules/
    s3-backend/
      s3.tf
      dynamodb.tf - removed
      variables.tf
      outputs.tf
    vpc/
      vpc.tf
      routes.tf
      variables.tf
      outputs.tf
    ecr/
      ecr.tf
      variables.tf
      outputs.tf
    eks/
      eks.tf
      variables.tf
      outputs.tf
  charts/
    django-app/
      Chart.yaml
      values.yaml
      templates/
        deployment.yaml
        service.yaml
        configmap.yaml
        hpa.yaml
README.md
```

**Примітка:** З останніми оновленнями було запроваджено вбудоване блокування станів на основі S3, що усуває необхідність в окремій таблиці **DynamoDB** для цієї мети. Цей новий підхід використовує файл блокування безпосередньо в самому корзині S3. Параметр **use_lockfile**, якщо його встановити в значення true, активує цей вбудований механізм блокування S3.

## Передумови
- Terraform >= 1.6
- AWS CLI v2, налаштовані облікові дані (aws configure)
- kubectl ≥ 1.27
- Helm 3 (встановити: brew install helm / Linux скрипт / choco)
- Docker (для білду образу)
- Регіон у прикладах: eu-north-1 (Стокгольм)

## Bootstrap бекенду (важливо)
Terraform не може використати бекенд S3, поки бакет/таблиця не існують. Тому:

```bash
	cd ./lesson-7
```

1. Ініціювати 
```bash
  terraform init -reconfigure
```	

2. **Тимчасово закоментувати** в `backend.tf` блок `terraform { backend "s3" {...} }`

2. Створити інфраструктуру для бекенду (S3 bucket):

```bash
  terraform apply -target=module.s3_backend \       
  -var-file=dev.tfvars \
  -auto-approve
```

Після цього вже є S3 bucket.

Примітка: на macOS **(M1)** при виникненні помилки ʼError: Failed to load plugin schemasʼ:
```bash
	export GODEBUG=asyncpreemptoff=1;
```

3. Увімкнути бекенд S3 — розкоментувати backend.tf, підставивши:

- bucket = унікальний бакет (з кроку 2)
- dynamodb_table = terraform-locks (або своя назва)
- region = регіон бакета (напр. eu-north-1)

3. Повторно ініціалізувати бекенд:
```bash
  terraform init -reconfigure
```	

4. Створити решту інфраструктури (звичайний запуск)
```bash
	terraform plan  -var-file=dev.tfvars
	terraform apply -var-file=dev.tfvars -auto-approve
```	

5. Підключення kubectl до EKS
5.1. Оновити kubeconfig (ім’я кластера з outputs):  
```bash
  CLUSTER_NAME=$(terraform output -raw eks_cluster_name)
  aws eks update-kubeconfig --region eu-north-1 --name "$CLUSTER_NAME"
```	

5.2. Додати aws-auth (щоб ноди приєдналися):  
```bash
  cat > aws-auth.yaml <<EOF
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: aws-auth
    namespace: kube-system
  data:
    mapRoles: |
      - rolearn: $(terraform output -raw eks_node_role_arn)
        username: system:node:{{EC2PrivateDNSName}}
        groups:
          - system:bootstrappers
          - system:nodes
  EOF

  kubectl apply -f aws-auth.yaml
  kubectl get nodes -o wide
```	

Чекайти, доки ноди перейдуть у Ready.  

6. Білд та пуш Django-образу в ECR
6.1. Логін:
```bash
  REGION=eu-north-1
  ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
  REPO=lesson-7-ecr
  ECR_URL="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO}"

  aws ecr get-login-password --region "$REGION" \
  | docker login --username AWS --password-stdin "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
```

6.2. У каталозі з Dockerfile:
**Код Django** має бути у каталозі, з якого запускається docker build (build context).
```bash
  docker build --platform linux/amd64 -t ${REPO}:1.0.0 .
  docker tag  ${REPO}:1.0.0 ${ECR_URL}:1.0.0
  docker push ${ECR_URL}:1.0.0
```

7. Деплой через Helm
```bash
  helm upgrade --install django-app ./charts/django-app
```

Перевірка:  
```bash
  kubectl get pods
  kubectl get svc
  kubectl get hpa
```

Коли у svc/django-app з’явиться EXTERNAL-IP — відкрити його у браузері.  

8. Видалення (teardown)
8.1. Видалити застосунок:
```bash
  helm uninstall django-app || true
```	

8.2. Видалити інфраструктуру:
```bash
	terraform destroy -var-file=dev.tfvars -auto-approve
```	

## Пояснення модулів
### s3-backend
1. S3 бакет з:
- версіюванням
- SSE (AES256)
- блокуванням публічного доступу
- вбудоване блокування станів на основі S3 (на заміну DynamoDB)
2. Виводи: bucket_name.

### vpc
1. VPC з CIDR (за замовчуванням 10.0.0.0/16).
2. 3 публічні та 3 приватні підмережі, рівномірно по AZ.
3. Internet Gateway для публічних маршрутів.
4. NAT Gateway: за замовчуванням один NAT. Можна змінити на один NAT на AZ (дорожче, але висока доступність), встановивши create_nat_per_az = true.
5. Окремі Route Tables: одна публічна, приватні — по AZ з маршрутом через свій NAT.
6. Виводи: vpc_id, igw_id, public_subnet_ids, private_subnet_ids, nat_gateway_ids.

### ecr
1. ECR репозиторій:
- scan_on_push (за замовчуванням true)
- політика доступу в межах акаунта на push/pull
- lifecycle policy: зберігати 30 останніх образів
2. Виводи: repository_name, repository_arn, repository_url.

### eks
- Кластер EKS + NodeGroup.
- IAM-ролі для кластера і нод.
- Виводи: cluster_name, cluster_endpoint, node_role_arn.

## Примітки
- Унікальність S3: назва бакета повинна бути глобально унікальною.
- Вартість: NAT GW — платний ресурс. Заощадити можна, виставивши create_nat_per_az = false (один NAT).
- AZ відповідність: стежити, щоб кількість public_subnets, private_subnets дорівнювала кількості availability_zones.
