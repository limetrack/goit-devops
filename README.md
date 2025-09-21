# Terraform AWS (S3+DynamoDB backend, VPC, ECR)

## Структура

```
lesson-5/
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
README.md
```

**Примітка:** З останніми оновленнями було запроваджено вбудоване блокування станів на основі S3, що усуває необхідність в окремій таблиці **DynamoDB** для цієї мети. Цей новий підхід використовує файл блокування безпосередньо в самому корзині S3. Параметр **use_lockfile**, якщо його встановити в значення true, активує цей вбудований механізм блокування S3.

## Передумови
- Terraform >= 1.6
- AWS облікові дані налаштовані (`aws configure` або змінні середовища).
- Вибрана регіональна пара AZ (за замовчуванням `eu-north-1a/b/c`).

## Bootstrap бекенду (важливо)
Terraform не може використати бекенд S3, поки бакет/таблиця не існують. Тому:

```bash
	cd ./lesson-5
```

1. Ініціювати 
```bash
  terraform init -reconfigure
```	

2. **Тимчасово закоментувати** в `backend.tf` блок `terraform { backend "s3" {...} }`

2. Створити інфраструктуру для бекенду:

```bash
  terraform apply -target=module.s3_backend \       
  -var-file=dev.tfvars \
  -auto-approve
```

Після цього вже є S3 bucket і DynamoDB table.

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

5. Видалення всіх ресурсів
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

## Примітки
- Унікальність S3: назва бакета повинна бути глобально унікальною.
- Вартість: NAT GW — платний ресурс. Заощадити можна, виставивши create_nat_per_az = false (один NAT).
- AZ відповідність: стежити, щоб кількість public_subnets, private_subnets дорівнювала кількості availability_zones.
