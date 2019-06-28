FROM nginx:1.12-alpine

RUN mkdir -p /var/www/certbot /etc/letsencrypt/conf /etc/letsencrypt/live
COPY nginx.tmpl /etc/nginx/nginx.tmpl
RUN apk update && apk add ca-certificates && update-ca-certificates && apk add openssl
RUN wget -O /etc/letsencrypt/conf/options-ssl-nginx.conf \
    https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/options-ssl-nginx.conf
RUN wget -O /etc/letsencrypt/conf/ssl-dhparams.pem \
    https://raw.githubusercontent.com/certbot/certbot/master/certbot/ssl-dhparams.pem
VOLUME [ "/var/log/nginx", "/etc/letsencrypt/live", "/var/www/certbot" ]
CMD /bin/sh -c 'envsubst "\$VIRTUAL_HOST \$NGINX_REVERSE_PROXY" < /etc/nginx/nginx.tmpl > /etc/nginx/nginx.conf; \
                while :; do sleep 6h & wait ${!}; \
                envsubst "\$VIRTUAL_HOST \$NGINX_REVERSE_PROXY" < /etc/nginx/nginx.tmpl > /etc/nginx/nginx.conf; \
                nginx -s reload; done & nginx -g "daemon off;"'
