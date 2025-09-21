# Django + PostgreSQL + Nginx (Docker Compose)

Цей проєкт містить приклад запуску вебзастосунку на **Django**, з базою **PostgreSQL** та реверс-проксі на **Nginx** у контейнерах Docker.  

## Запуск
  
1. У корені створити файл `.env` з параметрами:
   ```
   DJANGO_DEBUG=1
   DJANGO_SECRET_KEY=dev-secret-key
   POSTGRES_DB=postgres
   POSTGRES_USER=postgres
   POSTGRES_PASSWORD=postgres
  
2. Запуск:  
```docker compose up -d --build```

## Перевірка
  
Вебзастосунок: http://localhost  
PostgreSQL: localhost:5432 (логін/пароль з .env)  

<img width="1093" height="668" alt="Screenshot 2025-09-06 at 13 23 26" src="https://github.com/user-attachments/assets/8e53ffe5-2dc9-4d16-883a-54efc5501804" />
  
## Нотатки для macOS (M1/M2/M3, ARM)
- За замовчуванням Docker може тягнути linux/amd64 образи, що викликає емулювання (повільніше і з помилками).  
У docker-compose.yml додано параметр: ```platform: linux/arm64```. Це гарантує, що образи (postgres, nginx, django) запускаються під ARM.  
- Якщо виникає помилка does `not provide the specified platform (linux/amd64)`, перевірити, щоб не було змінної:  
```echo $DOCKER_DEFAULT_PLATFORM```  
Якщо виводить linux/amd64, прибрати:  
```unset DOCKER_DEFAULT_PLATFORM```  
- В налаштуваннях Docker Desktop > Virtual Machine Options встиновити Docker VMM (замість Apple Virtualization framework)  
