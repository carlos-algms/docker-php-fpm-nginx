ARG FROM_IMAGE=alpine:3.16
FROM $FROM_IMAGE

ARG BUILD_DATE
ARG VERSION
ARG PHP_VER=8

LABEL build_version="version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="carlosalgms"

ENV PS1="$(whoami)@$(hostname):$(pwd)\\$ " \
HOME="/root" \
TERM="xterm" \
PHP_VERSION=${PHP_VER}

ENTRYPOINT ["/sbin/tini", "--", "/init"]

RUN apk update && \
  apk upgrade --no-cache && \
  apk add --no-cache --upgrade \
    tini \
    bash \
    zsh \
    htop \
    ca-certificates \
    openssl \
    coreutils \
    curl \
    tar \
    tzdata \
    xz \
    procps \
    shadow \
    vim \
    nginx

RUN echo "**** create user and make our folders ****" && \
  groupmod -g 1000 users && \
  useradd -u 1000 -g www-data -d /config -s /bin/false www-data && \
  usermod -G users www-data && \
  mkdir -p \
    /app \
    /config \
    /defaults


## Todo: move it to the top level install
RUN \
  apk add --no-cache --upgrade \
    php${PHP_VER} \
    php${PHP_VER}-fpm \
    php${PHP_VER}-fileinfo \
    php${PHP_VER}-json \
    php${PHP_VER}-mbstring \
    php${PHP_VER}-openssl \
    php${PHP_VER}-session \
    php${PHP_VER}-simplexml \
    php${PHP_VER}-xml \
    php${PHP_VER}-xmlwriter \
    php${PHP_VER}-xmlreader \
    php${PHP_VER}-xsl \
    php${PHP_VER}-zlib \
    php${PHP_VER}-gd \
    php${PHP_VER}-mysqli \
    php${PHP_VER}-pdo_mysql \
    php${PHP_VER}-sqlite3 \
    php${PHP_VER}-pdo_sqlite \
    php${PHP_VER}-opcache \
    php${PHP_VER}-pspell \
    php${PHP_VER}-bcmath \
    php${PHP_VER}-exif \
    php${PHP_VER}-zip \
    php${PHP_VER}-pcntl \
    php${PHP_VER}-phar \
    php${PHP_VER}-pecl-imagick \
    php${PHP_VER}-pecl-mcrypt


RUN \
  echo "**** configure Nginx ****" && \
    rm -f /etc/nginx/http.d/default.conf && \
    sed -i 's#^user nginx;#user www-data;#g' /etc/nginx/nginx.conf && \
    sed -i 's#/var/log/#/config/log/#g' /etc/nginx/nginx.conf && \
    sed -i 's#client_max_body_size 1m;#client_max_body_size 0;#g' /etc/nginx/nginx.conf && \
    sed -i 's#include /etc/nginx/http.d/\*.conf;#include /config/nginx/site-confs/\*.conf;#g' /etc/nginx/nginx.conf && \
    echo -e  '\n\ndaemon off;\npid /run/nginx.pid;\n' >> /etc/nginx/nginx.conf && \
  echo "**** configure PHP ****" && \
    mv /etc/php${PHP_VER} /etc/php && \
    ln -s /etc/php /etc/php${PHP_VER} && \
    [ ! -f "/usr/bin/php" ] &&  ln -s /usr/bin/php${PHP_VER} /usr/bin/php || true  && \
    ln -s /usr/sbin/php-fpm8 /usr/sbin/php-fpm && \
    sed -i "s#user = nobody.*#user = www-data#g" \
      /etc/php${PHP_VER}/php-fpm.d/www.conf && \
    sed -i "s#group = nobody.*#group = www-data#g" \
      /etc/php${PHP_VER}/php-fpm.d/www.conf && \
    echo -e  '\n\ninclude=/config/php/php-fpm.d/*.conf\n' >> /etc/php/php-fpm.conf


# add local files
COPY root-fs/ /
