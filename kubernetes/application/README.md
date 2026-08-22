# Развёртывание приложения

Манифесты создают два экземпляра приложения, внутренний Service и Ingress для домена `netology-devops-diplom.neelov.family`. Образ обновляется workflow `diplom-app.yml` после публикации в Yandex Container Registry и GitHub Container Registry.

Namespace и права сервисного аккаунта CI создаются один раз после запуска кластера:

```bash
kubectl apply -f namespace.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f ingress.yaml
```

Проверка состояния:

```bash
kubectl get deployment,pods,service,ingress -n diplom
kubectl rollout status deployment/diplom-app -n diplom
```
