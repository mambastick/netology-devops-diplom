# Мониторинг Kubernetes

Для мониторинга используется chart `kube-prometheus-stack` версии `88.5.3`. Он устанавливает Prometheus Operator, Prometheus, Alertmanager, Grafana, kube-state-metrics и node-exporter вместе с готовыми дашбордами и правилами.

Компоненты control plane, недоступные в Managed Kubernetes, исключены из сбора метрик и правил оповещения.

## Установка

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  --version 88.5.3 \
  --namespace monitoring \
  --create-namespace \
  --values values.yaml \
  --wait \
  --timeout 15m
```

Полная команда установки с образами, зеркалированными в Yandex Container Registry, находится в workflow `diplom-platform.yml`.

## Доступ к Grafana

```bash
kubectl get ingress monitoring-grafana -n monitoring
kubectl get secret monitoring-grafana -n monitoring \
  -o jsonpath='{.data.admin-password}' | base64 --decode
```

Grafana открывается по адресу `https://grafana.netology-devops-diplom.neelov.family`. Для просмотра дашбордов вход не нужен; анонимной сессии выдана только роль `Viewer`. Административный пользователь — `admin`.
