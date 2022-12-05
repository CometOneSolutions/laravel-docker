FROM nginx:stable-alpine

ENV NGINXUSER=laravel
ENV NGINXGROUP=laravel

RUN mkdir -p /var/www/html/public

ADD nginx/default.conf /etc/nginx/conf.d/default.conf

RUN sed -i "s/user www-data/user ${NGINXUSER}/g" /etc/nginx/nginx.conf

RUN adduser -g ${NGINXGROUP} -s /bin/sh -D ${NGINXUSER}

# RUN apk update
# RUN apk add supervisor openvpn
# COPY vpn-config/vpn.conf /etc/supervisor/conf.d/openvpn.conf

# CMD /usr/bin/supervisord --nodaemon
