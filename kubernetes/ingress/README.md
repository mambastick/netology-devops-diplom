# HTTPS для приложения и Grafana

Внешний трафик принимает ingress-nginx. Сертификаты для приложения и Grafana выпускает cert-manager через Let's Encrypt.

## Установка

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add jetstack https://charts.jetstack.io
helm repo update

helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --version 4.15.1 \
  --namespace ingress-nginx \
  --create-namespace \
  --values values.yaml \
  --wait

helm upgrade --install cert-manager jetstack/cert-manager \
  --version v1.21.1 \
  --namespace cert-manager \
  --create-namespace \
  --set crds.enabled=true \
  --set imageRegistry=cr.yandex \
  --set imageNamespace="$CONTAINER_REGISTRY_ID" \
  --wait

kubectl apply -f cluster-issuer.yaml
```

После появления внешнего адреса ingress нужно направить на него две A-записи:

- `netology-devops-diplom.neelov.family`;
- `grafana.netology-devops-diplom.neelov.family`.

Проверка сертификатов:

```bash
kubectl get ingress --all-namespaces
kubectl get certificate --all-namespaces
```

Образы cert-manager предварительно зеркалируются в Yandex Container Registry. Это делает workflow `diplom-platform.yml`.
