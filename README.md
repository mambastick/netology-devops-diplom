# Дипломный проект в Yandex Cloud

[Задание на диплом](https://github.com/netology-code/devops-diplom-yandexcloud)

Для диплома я развернул в Yandex Cloud региональный кластер Managed Kubernetes, небольшое nginx-приложение и мониторинг на базе Prometheus и Grafana. Инфраструктура описана в Terraform, а сборка и деплой приложения выполняются через GitHub Actions.

После проверки стенд был удалён, чтобы не оставлять платные облачные ресурсы. Скриншоты ниже сделаны до удаления.

## Инфраструктура

Terraform разделён на две части. Конфигурация в [`terraform/bootstrap`](terraform/bootstrap) создаёт сервисные аккаунты, KMS-ключ и бакет Object Storage для state. Основная конфигурация находится в [`terraform/infrastructure`](terraform/infrastructure): там описаны сеть, три подсети, Container Registry и региональный Kubernetes-кластер.

Worker-ноды были прерываемыми и находились в трёх зонах: `ru-central1-a`, `ru-central1-b` и `ru-central1-d`. Приложение работало в двух экземплярах и публиковалось через `LoadBalancer`.

## Приложение и мониторинг

Тестовая страница собирается из каталога [`app`](app). nginx запускается без root-прав на порту `8080`, а для проверки доступен endpoint `/healthz`.

Манифесты приложения лежат в [`kubernetes/application`](kubernetes/application). Настройки `kube-prometheus-stack` находятся в [`kubernetes/monitoring`](kubernetes/monitoring). В Grafana использовались готовые Kubernetes-дашборды, а Prometheus собирал метрики со всех трёх worker-нод.

## Автоматизация

Workflow [`diplom-terraform.yml`](.github/workflows/diplom-terraform.yml) проверяет форматирование Terraform, выполняет `init`, `validate`, `plan` и применяет изменения из `main`.

Workflow [`diplom-app.yml`](.github/workflows/diplom-app.yml) собирает Docker-образ, публикует его в Yandex Container Registry и обновляет Deployment в namespace `diplom`. При создании тега `v1.0.0` приложение было собрано и развёрнуто с таким же тегом.

- [успешный запуск Terraform](https://github.com/mambastick/netology-devops-diplom/actions/runs/31328503689);
- [сборка и деплой версии v1.0.0](https://github.com/mambastick/netology-devops-diplom/actions/runs/31330292867).

## Проверка

Основные команды, которыми я проверял стенд:

```bash
terraform -chdir=terraform/infrastructure plan
kubectl get nodes
kubectl get pods --all-namespaces
kubectl get deployment,pods,service -n diplom
helm status monitoring -n monitoring
```

### Приложение

![Тестовое приложение](docs/screenshots/application.png)

### Состояние Kubernetes

![Состояние Kubernetes](docs/screenshots/kubernetes-status.png)

### Мониторинг

![Дашборд Grafana](docs/screenshots/grafana-nodes.png)

### Деплой приложения

![Успешный pipeline приложения](docs/screenshots/github-actions-app.png)

### Terraform

![Успешный pipeline Terraform](docs/screenshots/github-actions-terraform.png)

Остальные снимки с выводом Terraform и `kubectl` находятся в каталоге [`docs/screenshots`](docs/screenshots).
