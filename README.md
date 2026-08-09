# Дипломный практикум в Yandex Cloud

[Оригинальное задание](https://github.com/netology-code/devops-diplom-yandexcloud)

## Цель проекта

Подготовить в Yandex Cloud воспроизводимую инфраструктуру для Kubernetes, развернуть тестовое приложение и систему мониторинга, а также автоматизировать изменение инфраструктуры, сборку Docker-образа и его доставку в кластер.

## План реализации

1. Terraform создаёт сервисный аккаунт и Object Storage для хранения state.
2. Отдельная Terraform-конфигурация создаёт VPC, подсети, группы безопасности, Container Registry и кластер Managed Kubernetes.
3. В Kubernetes устанавливаются ingress-контроллер и стек мониторинга Prometheus, Grafana, Alertmanager и node_exporter.
4. Тестовое nginx-приложение хранится в каталоге `app` вместе с Dockerfile и pipeline.
5. GitHub Actions проверяет и применяет Terraform, собирает и публикует Docker-образ, а при создании тега разворачивает новую версию в Kubernetes.

## Структура проекта

```text
netology-devops-diplom/
├── app/                     # тестовое приложение и Dockerfile
├── terraform/
│   ├── bootstrap/           # сервисный аккаунт и backend
│   └── infrastructure/      # основная облачная инфраструктура
├── kubernetes/
│   ├── application/         # манифесты тестового приложения
│   └── monitoring/          # Helm values и манифесты мониторинга
├── docs/screenshots/                # скриншоты и результаты проверок
└── README.md
```

Pipeline для основной Terraform-конфигурации находится в [`.github/workflows/diplom-terraform.yml`](.github/workflows/diplom-terraform.yml).

## Ожидаемый результат

- инфраструктура создаётся и удаляется без ручной настройки ресурсов;
- Terraform state хранится в Object Storage;
- `kubectl get pods --all-namespaces` выполняется без ошибок;
- тестовое приложение и Grafana доступны из интернета;
- дашборды Grafana отображают состояние Kubernetes;
- коммит собирает Docker-образ, а тег публикует и разворачивает версию с соответствующей меткой.
