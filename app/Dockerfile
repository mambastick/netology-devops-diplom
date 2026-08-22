FROM nginx:1.30.4-alpine

ARG APP_VERSION=dev

LABEL org.opencontainers.image.source="https://github.com/mambastick/netology-devops-diplom"
LABEL org.opencontainers.image.description="Test application for the Netology DevOps diploma"

COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /usr/share/nginx/html/index.html

RUN sed -i "s/__APP_VERSION__/${APP_VERSION}/g" /usr/share/nginx/html/index.html

USER nginx

EXPOSE 8080

HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -q -O - http://127.0.0.1:8080/healthz || exit 1
