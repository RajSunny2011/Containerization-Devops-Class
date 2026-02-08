FROM alpine:latest
RUN apk add --no-cache nginx
RUN echo "server { \
    listen 80 default_server; \
    listen [::]:80 default_server; \
    root /var/www/html; \
    index index.html index.htm; \
    server_name _; \
    location / { \
        try_files \$uri \$uri/ =404; \
    } \
}" > /etc/nginx/http.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]