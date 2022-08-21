ARG FROM_IMAGE=alpine:3.16
FROM $FROM_IMAGE

ARG EXTRA_REPO=""

LABEL maintainer="carlosalgms"

ENV PS1="$(whoami)@$(hostname):$(pwd)\\$ " \
HOME="/root" \
TERM="xterm"

ENTRYPOINT ["/sbin/tini", "--", "/init"]

RUN \
  ( \
    [ ! -z "${EXTRA_REPO}" ] && \
    echo "http://dl-cdn.alpinelinux.org/alpine/v${EXTRA_REPO}/main" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/v${EXTRA_REPO}/community" >> /etc/apk/repositories \
  ) || \
  apk update && \
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

ARG PHP_VER=8
ARG VARIABLE_DEPS=" php${PHP_VER}-pecl-mcrypt "

RUN \
  apk add --no-cache --upgrade --force \
    php${PHP_VER} \
    php${PHP_VER}-bcmath \
    php${PHP_VER}-exif \
    php${PHP_VER}-fileinfo \
    php${PHP_VER}-fpm \
    php${PHP_VER}-gd \
    php${PHP_VER}-json \
    php${PHP_VER}-mbstring \
    php${PHP_VER}-mysqli \
    php${PHP_VER}-opcache \
    php${PHP_VER}-openssl \
    php${PHP_VER}-pcntl \
    php${PHP_VER}-pdo_mysql \
    php${PHP_VER}-pdo_sqlite \
    php${PHP_VER}-pear \
    php${PHP_VER}-phar \
    php${PHP_VER}-pspell \
    php${PHP_VER}-session \
    php${PHP_VER}-simplexml \
    php${PHP_VER}-sqlite3 \
    php${PHP_VER}-xml \
    php${PHP_VER}-xmlreader \
    php${PHP_VER}-xmlwriter \
    php${PHP_VER}-xsl \
    php${PHP_VER}-zip \
    php${PHP_VER}-zlib \
    ${VARIABLE_DEPS}


RUN \
  echo "**** create user and make our folders ****" && \
    groupmod -g 1000 users && \
    useradd -u 1000 -g www-data -d /config -s /bin/false www-data && \
    usermod -G users www-data && \
    mkdir -p \
      /app \
      /config \
      /defaults && \
  echo "**** configure Nginx ****" && \
    rm -f /etc/nginx/http.d/default.conf && \
    sed -i 's#^user nginx;#user www-data;#g' /etc/nginx/nginx.conf && \
    sed -i 's#/var/log/#/config/log/#g' /etc/nginx/nginx.conf && \
    sed -i 's#client_max_body_size 1m;#client_max_body_size 0;#g' /etc/nginx/nginx.conf && \
    sed -i 's#include /etc/nginx/http.d/\*.conf;#include /config/nginx/site-confs/\*.conf;#g' /etc/nginx/nginx.conf && \
    printf '\n\npid /run/nginx.pid;\n' >> /etc/nginx/nginx.conf && \
  echo "**** configure PHP ****" && \
    mv /etc/php${PHP_VER} /etc/php && \
    ln -s /etc/php /etc/php${PHP_VER} && \
    ! (command -v php &> /dev/null) && ln -s `command -v php${PHP_VER}` /usr/bin/php || true  && \
    ! (command -v php-fpm &> /dev/null) &&  ln -s `which php-fpm${PHP_VER}` /usr/sbin/php-fpm || true

# add local files
COPY root-fs/ /


ARG BUILD_DATE
ARG VERSION
LABEL build_version="version:- ${VERSION} Build-date:- ${BUILD_DATE}"
