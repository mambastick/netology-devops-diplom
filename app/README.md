# Тестовое приложение

Статическая страница обслуживается nginx от непривилегированного пользователя на порту `8080`.

## Локальный запуск

```bash
docker build --build-arg APP_VERSION=local -t diplom-app:local .
docker run --rm -p 8080:8080 diplom-app:local
```

Проверка readiness endpoint:

```bash
curl http://127.0.0.1:8080/healthz
```
