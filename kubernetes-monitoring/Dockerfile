FROM nginx:1.25-alpine

RUN apk add --no-cache curl

# Копируем базовую конфигурацию
COPY nginx.conf /etc/nginx/nginx.conf

# Создаем директорию для логов
RUN mkdir -p /var/log/nginx && chown -R nginx:nginx /var/log/nginx

# Открываем порт метрик
EXPOSE 9113

CMD ["nginx", "-g", "daemon off;"]
