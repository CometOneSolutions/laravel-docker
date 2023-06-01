FROM surnet/alpine-wkhtmltopdf:3.16.2-0.12.6-small as wkhtmltopdf
FROM php:8.1-fpm-alpine

ARG UID
ARG GID

ENV UID=${UID}
ENV GID=${GID}

RUN mkdir -p /var/www/html/public
WORKDIR /var/www/html

# The MacOS staff group gid is 20, so is the dialout group in alpine linux. We're not using it, so we're just going to remove it.
RUN delgroup dialout

RUN addgroup -g ${GID} --system laravel
RUN adduser -G laravel --system -D -s /bin/sh -u ${UID} laravel

RUN sed -i "s/user = www-data/user = laravel/g" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i "s/group = www-data/group = laravel/g" /usr/local/etc/php-fpm.d/www.conf

RUN docker-php-ext-install pdo pdo_mysql

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions && \
    IPE_GD_WITHOUTAVIF=1 install-php-extensions gd exif zip intl @composer

# Install dependencies for wkhtmltopdf
RUN apk add --no-cache \
    libstdc++ \
    libx11 \
    libxrender \
    libxext \
    libssl1.1 \
    ca-certificates \
    fontconfig \
    freetype \
    ttf-dejavu \
    ttf-droid \
    ttf-freefont \
    ttf-liberation \
    # more fonts
    && apk add --no-cache --virtual .build-deps \
    msttcorefonts-installer \
    # Install microsoft fonts
    && update-ms-fonts \
    && fc-cache -f \
    # Clean up when done
    && rm -rf /tmp/* \
    && apk del .build-deps

COPY --from=wkhtmltopdf /bin/wkhtmltopdf /bin/wkhtmltopdf

CMD ["php-fpm", "-y", "/usr/local/etc/php-fpm.conf", "-R"]
