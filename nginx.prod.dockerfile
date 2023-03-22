FROM nginx:stable-alpine

ENV NGINXUSER=laravel
ENV NGINXGROUP=laravel

RUN mkdir -p /var/www/html/public

ADD nginx/default.prod.conf /etc/nginx/conf.d/default.conf

ADD certs/ssl_certificate.csr /etc/nginx/certs/ssl_certificate.csr
ADD certs/ssl_certificate_secret.key /etc/nginx/certs/ssl_certificate_secret.key

RUN sed -i "s/user www-data/user ${NGINXUSER}/g" /etc/nginx/nginx.conf

RUN adduser -g ${NGINXGROUP} -s /bin/sh -D ${NGINXUSER}
