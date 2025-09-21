# CI/CD Pipeline: Jenkins + Terraform + Helm + Argo CD

Повний CI/CD процес для Django додатку з використанням Jenkins, Terraform, Helm і Argo CD на AWS EKS.

## 🏗️ Архітектура

```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐    ┌─────────────┐
│   GitHub    │───▶│   Jenkins    │───▶│     ECR     │───▶│   Argo CD   │
│  (Source)   │    │ (CI/Build)   │    │  (Registry) │    │ (GitOps CD) │
└─────────────┘    └──────────────┘    └─────────────┘    └─────────────┘
                            │                                     │
                            ▼                                     ▼
                   ┌──────────────┐                      ┌─────────────┐
                   │   Git Repo   │                      │  EKS Cluster│
                   │ (Helm Charts)│◀─────────────────────│ (Deployment)│
                   └──────────────┘                      └─────────────┘
```

## 📁 Структура проекту

```
devops/
├── main.tf                    # Головний Terraform файл
├── backend.tf                 # S3 backend конфігурація
├── variables.tf               # Змінні
├── outputs.tf                 # Виводи
├── dev.tfvars                 # Значення змінних для dev середовища
├── modules/
│   ├── s3-backend/           # S3 бакет для Terraform state
│   ├── vpc/                  # AWS VPC з підмережами
│   ├── ecr/                  # Docker registry
│   ├── eks/                  # Kubernetes кластер
│   ├── rds/                  # Managed PostgreSQL/Aurora база даних
│   ├── jenkins/              # Jenkins CI/CD сервер
│   └── argo-cd/              # GitOps CD інструмент
└── charts/
    └── django-app/           # Helm chart для Django
        ├── Chart.yaml
        ├── values.yaml
        └── templates/
            ├── deployment.yaml
            ├── service.yaml
            ├── configmap.yaml
            └── hpa.yaml
```

## 🚀 Швидкий старт

### Передумови

- **Terraform** >= 1.6
- **AWS CLI v2** з налаштованими credentials
- **kubectl** >= 1.27
- **Helm 3**
- **Docker**
- **Git**

### Крок 1: Підготовка середовища

```bash
# Клонувати репозиторій
git clone <repository-url>
cd goit-HW-DevOps/devops

# Перевірити AWS credentials
aws sts get-caller-identity

# Оновити dev.tfvars з вашими значеннями
cp terraform.tfvars.example dev.tfvars
# Відредагувати dev.tfvars
```

### Крок 2: Bootstrap Terraform backend

```bash
# Тимчасово закоментувати backend в backend.tf

# Ініціалізація
terraform init

# Створити S3 bucket для state
terraform apply -target=module.s3_backend -var-file=dev.tfvars -auto-approve

# Розкоментувати backend.tf і повторно ініціалізувати
terraform init -reconfigure
```
  
**Примітка:** на macOS **(M1)** при виникненні помилки ʼError: Failed to load plugin schemasʼ:
```bash
export GODEBUG=asyncpreemptoff=1;
```
  
### Крок 3: Розгортання інфраструктури

```bash
# Спланувати зміни
terraform plan -var-file=dev.tfvars

# Застосувати конфігурацію
terraform apply -var-file=dev.tfvars -auto-approve
```

### Крок 4: Налаштування kubectl

```bash
# Отримати назву кластера
CLUSTER_NAME=$(terraform output -raw cluster_name)

# Оновити kubeconfig
aws eks update-kubeconfig --region eu-north-1 --name "$CLUSTER_NAME"

# Перевірити підключення
kubectl get nodes
```

### Крок 5: Доступ до Jenkins

```bash
# Отримати Jenkins URL
kubectl get svc jenkins -n jenkins

# Credentials: admin / SecurePassword123! (або як в dev.tfvars)
```

### Крок 6: Доступ до Argo CD

```bash
# Отримати Argo CD URL
kubectl get svc argo-cd-argocd-server -n argocd

# Отримати admin пароль
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

## 🔄 CI/CD Workflow

### 1. Continuous Integration (Jenkins)

1. **Trigger**: Push в GitHub репозиторій
2. **Build**: Kaniko будує Docker образ
3. **Push**: Образ завантажується в ECR
4. **Update**: Jenkins оновлює tag в Helm values.yaml
5. **Commit**: Зміни пушаться назад в Git

### 2. Continuous Deployment (Argo CD)

1. **Detect**: Argo CD виявляє зміни в Git
2. **Sync**: Автоматична синхронізація з кластером
3. **Deploy**: Розгортання нової версії додатку
4. **Monitor**: Моніторинг стану деплойменту

## 🔧 Конфігурація

### RDS База даних

Інфраструктура підтримує як звичайні RDS інстанси, так і Aurora кластери. Налаштування в `dev.tfvars`:

#### Базова конфігурація RDS
```hcl
# Назва бази даних
rds_name = "myapp-db"

# Використовувати Aurora кластер (false для звичайного RDS)
rds_use_aurora = false

# Aurora-специфічні налаштування (коли rds_use_aurora = true)
rds_aurora_instance_count = 2
rds_engine_cluster = "aurora-postgresql"
rds_engine_version_cluster = "15.3"
rds_parameter_group_family_aurora = "aurora-postgresql15"

# Звичайний RDS (коли rds_use_aurora = false)
rds_engine = "postgres"
rds_engine_version = "17.2"
rds_parameter_group_family = "postgres17"

# Спільні налаштування
rds_instance_class = "db.t3.medium"
rds_allocated_storage = 20
rds_db_name = "myapp"
rds_username = "postgres"
rds_password = "your-secure-password"
rds_publicly_accessible = false  # false для production
rds_multi_az = true
rds_backup_retention_period = 7

# Параметри бази даних
rds_parameters = {
  max_connections = "200"
  log_min_duration_statement = "500"
}

# Теги для RDS ресурсів
rds_tags = {
  Environment = "dev"
  Project = "myapp"
}
```

#### RDS vs Aurora

**Використовуйте звичайний RDS коли:**
- Простий single-instance setup
- Оптимізація вартості є пріоритетом
- Стандартних функцій PostgreSQL достатньо

**Використовуйте Aurora коли:**
- Висока доступність критична
- Потрібне масштабування читання
- Потрібні розширені функції PostgreSQL
- Multi-region setup

#### Безпека бази даних

- Встановіть `rds_publicly_accessible = false` для production
- Використовуйте надійні паролі або AWS Secrets Manager
- Налаштуйте security groups для обмеження доступу
- Увімкніть шифрування в спокої та при передачі

### Jenkins Pipeline

Jenkins налаштований з:
- **Kubernetes agents** для ізольованого виконання
- **Kaniko** для безпечного білду образів
- **GitHub інтеграція** для автоматичних тригерів
- **ECR permissions** для пушу образів

### Argo CD Applications

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: django-app
spec:
  source:
    repoURL: https://github.com/user/repo.git
    path: charts/django-app
    targetRevision: main
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

### Helm Chart Features

- **HPA** (Horizontal Pod Autoscaler): 2-6 реплік
- **Health checks**: Readiness і Liveness probes
- **Resource limits**: CPU/Memory обмеження
- **ConfigMap**: Environment variables
- **LoadBalancer**: Зовнішній доступ

## 🧪 Тестування

### Тест CI/CD Pipeline

```bash
# 1. Зробити зміни в коді
echo "# Test change" >> README.md

# 2. Зафіксувати зміни
git add .
git commit -m "Test CI/CD pipeline"
git push origin main

# 3. Відстежити в Jenkins
# Jenkins UI -> goit-django-docker job

# 4. Перевірити Argo CD
# Argo CD UI -> django-app application

# 5. Перевірити деплоймент
kubectl get pods
kubectl get svc
```

### Перевірка доступності

```bash
# Отримати URL додатку
kubectl get svc django-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Або використати port-forward
kubectl port-forward svc/django-app 8080:80
```

## 🔍 Моніторинг та Logs

### Jenkins
```bash
# Логи Jenkins
kubectl logs -f deployment/jenkins -n jenkins

# Pipeline логи через UI
```

### Argo CD
```bash
# Логи Argo CD
kubectl logs -f deployment/argocd-server -n argocd

# Статус додатків
kubectl get applications -n argocd
```

### Django App
```bash
# Логи додатку
kubectl logs -f deployment/django-app

# Метрики HPA
kubectl get hpa
```

### RDS База даних
```bash
# Статус RDS інстансу
aws rds describe-db-instances --db-instance-identifier myapp-db

# Підключення до бази (з EKS pod)
kubectl run psql --rm -i --tty --image postgres:17 -- psql -h <rds-endpoint> -U postgres -d myapp

# Перевірка Aurora кластеру (якщо використовується)
aws rds describe-db-clusters --db-cluster-identifier myapp-db
```

## 🛠️ Troubleshooting

### Часті проблеми

1. **Jenkins pod не стартує**
   ```bash
   kubectl describe pod jenkins-xxx -n jenkins
   kubectl logs jenkins-xxx -n jenkins
   ```

2. **ECR authentication issues**
   ```bash
   # Перевірити IAM права для Jenkins SA
   kubectl describe sa jenkins-sa -n jenkins
   ```

3. **Argo CD не синхронізує**
   ```bash
   # Перевірити repository credentials
   kubectl get secrets -n argocd
   ```

4. **Django app не запускається**
   ```bash
   kubectl describe deployment django-app
   kubectl logs -f deployment/django-app
   ```

5. **RDS connection issues**
   ```bash
   # Перевірити security groups
   aws ec2 describe-security-groups --group-ids <rds-sg-id>

   # Перевірити доступність RDS
   aws rds describe-db-instances --db-instance-identifier myapp-db

   # Тест підключення з EKS
   kubectl run db-test --rm -i --tty --image postgres:17 -- psql -h <rds-endpoint> -U postgres -d myapp
   ```

## 🧹 Очищення

```bash
# Видалити Helm releases
helm uninstall django-app || true

# Видалити всю інфраструктуру
terraform destroy -var-file=dev.tfvars -auto-approve
```

## 📊 Компоненти та версії

| Компонент | Версія | Призначення |
|-----------|--------|-------------|
| Terraform | >= 1.6 | Infrastructure as Code |
| AWS EKS | 1.28 | Kubernetes кластер |
| AWS RDS | PostgreSQL 17.2 / Aurora 15.3 | Managed база даних |
| Jenkins | 5.8.27 | CI/CD сервер |
| Argo CD | 5.46.4 | GitOps деплоймент |
| Helm | 3.x | Package manager |
| Kaniko | v1.16.0 | Container builds |

## 🔒 Безпека

- **Secrets management**: Kubernetes Secrets
- **RBAC**: Role-based access control
- **Network policies**: Ізоляція трафіку  
- **Image scanning**: ECR vulnerability scanning
- **HTTPS**: TLS для всіх сервісів

## 📚 Додаткові ресурси

- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [Argo CD Documentation](https://argo-cd.readthedocs.io/)
- [Helm Charts](https://helm.sh/docs/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/)

---

**Примітка**: Цей README описує production-ready CI/CD pipeline. Для development середовища деякі налаштування можуть бути спрощені.