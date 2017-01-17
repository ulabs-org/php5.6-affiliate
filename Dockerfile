FROM php:5-fpm-alpine

ENV TERM xterm
ENV IONCUBE_URL "http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz"

RUN apk add --no-cache --virtual .build-deps \
      freetype-dev \
      jpeg-dev \
      libpng-dev \
      libxpm-dev \
      libtool \
      coreutils \
      autoconf \
      file \
      g++ \
      gcc \
      libc-dev \
      make \
      pkgconf \
      re2c \
      icu-dev \
    && apk add --no-cache icu libx11 libxpm libpng libjpeg freetype \
    # Install IonCube Loader:
    && curl -sfSL $IONCUBE_URL -o ioncube.tar.gz \
    && tar xvfz ioncube.tar.gz \
    && PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;") \
    && PHP_EXT_DIR=$(php-config --extension-dir) \
    && mkdir -p $PHP_EXT_DIR \
    && cp "ioncube/ioncube_loader_lin_${PHP_VERSION}.so" $PHP_EXT_DIR \
    && rm -rf ioncube ioncube.tar.gz \
    && docker-php-ext-configure \
      gd \
      --with-freetype-dir=/usr/include/ \
      --with-jpeg-dir=/usr/include/ \
      --with-png-dir=/usr/include/ \
      --with-xpm-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) \
      gd \
      intl \
      pcntl \
      mysqli \
      opcache \
      pdo_mysql \
    && docker-php-ext-enable \
      gd \
      intl \
      pcntl \
      mysqli \
      opcache \
      pdo_mysql \
    && apk del .build-deps \
    # Clean caches and temp-files:
    && rm -rf /var/cache/apk/* 2> /dev/null || echo "OK" \
    && rm -rf /usr/src 2> /dev/null || echo "OK" \
    && rm -rf /tmp/* 2> /dev/null || echo "OK" \
    && rm -rf /tmp/.* 2> /dev/null || echo "OK" \
    && rm -rf /root/* 2> /dev/null || echo "OK" \
    && rm -rf /root/.* 2> /dev/null || echo "OK"