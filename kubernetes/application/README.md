# Развёртывание приложения

Манифесты создают два экземпляра приложения и публичный `LoadBalancer` на порту `80`. Образ обновляется workflow `diplom-app.yml` после публикации в Container Registry.

Проверка состояния:

```bash
kubectl get deployment,pods,service -n diplom
kubectl rollout status deployment/diplom-app -n diplom
```
