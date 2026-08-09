# Развёртывание приложения

Манифесты создают два экземпляра приложения и публичный `LoadBalancer` на порту `80`. Образ обновляется workflow `diplom-app.yml` после публикации в Container Registry.

Namespace и права сервисного аккаунта CI создаются один раз после запуска кластера:

```bash
kubectl apply -f namespace.yaml
kubectl apply -f ci-rbac.yaml
```

Проверка состояния:

```bash
kubectl get deployment,pods,service -n diplom
kubectl rollout status deployment/diplom-app -n diplom
```
