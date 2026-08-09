# Мониторинг Kubernetes

Для мониторинга используется chart `kube-prometheus-stack` версии `88.2.0`. Он устанавливает Prometheus Operator, Prometheus, Alertmanager, Grafana, kube-state-metrics и node-exporter вместе с готовыми дашбордами и правилами.

Компоненты control plane, недоступные в Managed Kubernetes, исключены из сбора метрик и правил оповещения.

## Установка

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  --version 88.2.0 \
  --namespace monitoring \
  --create-namespace \
  --values values.yaml \
  --wait \
  --timeout 15m
```

## Доступ к Grafana

```bash
kubectl get service monitoring-grafana -n monitoring
kubectl get secret monitoring-grafana -n monitoring \
  -o jsonpath='{.data.admin-password}' | base64 --decode
```

Имя пользователя по умолчанию: `admin`. Web-интерфейс публикуется отдельным `LoadBalancer` на порту `80`.
