ARG FROM_IMAGE=alpine:3.16
FROM $FROM_IMAGE

ARG EXTRA_REPO=""

LABEL maintainer="carlosalgms"

ENV PS1="$(whoami)@$(hostname):$(pwd)\\$ " \
HOME="/root" \
TERM="xterm"

ENTRYPOINT ["/sbin/tini", "--", "/init"]

ARG PHP_VER=81
# Alpine 3.16 doesn't include php81-pecl-mcrypt - https://pkgs.alpinelinux.org/packages?name=php81*mcrypt&branch=v3.16&repo=&arch=&maintainer=
# Leaving it empty until it is available for php81
ARG VARIABLE_DEPS=""


RUN \
  ( \
    [ ! -z "${EXTRA_REPO}" ] && \
    echo "http://dl-cdn.alpinelinux.org/alpine/v${EXTRA_REPO}/main" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/v${EXTRA_REPO}/community" >> /etc/apk/repositories \
  ) || \
  apk upgrade --no-cache && \
  apk add --no-cache --upgrade \
    bash \
    ca-certificates \
    coreutils \
    curl \
    htop \
    logrotate \
    nginx \
    openssl \
    procps \
    shadow \
    tar \
    tini \
    tzdata \
    vim \
    xz \
    zsh && \
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
    ${VARIABLE_DEPS} && \
  echo "**** configure PHP ****" && \
    mv /etc/php${PHP_VER} /etc/php && \
    ln -s /etc/php /etc/php${PHP_VER} && \
    ! (command -v php &> /dev/null) && ln -s `command -v php${PHP_VER}` /usr/bin/php || true  && \
    ! (command -v php-fpm &> /dev/null) &&  ln -s `which php-fpm${PHP_VER}` /usr/sbin/php-fpm || true


# https://getcomposer.org/download/
ARG COMPOSER_VERSION="2.4.1"

RUN curl "https://getcomposer.org/installer" --output "composer-setup.php" \
  && php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
  && php composer-setup.php \
    --install-dir=/usr/local/bin \
    --filename=composer \
    --version=${COMPOSER_VERSION} \
  && rm "composer-setup.php"

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
    sed -i 's/^user /#user /g' /etc/nginx/nginx.conf && \
    sed -i 's#/var/log/#/config/log/#g' /etc/nginx/nginx.conf && \
    sed -i 's#client_max_body_size 1m;#client_max_body_size 0;#g' /etc/nginx/nginx.conf && \
    sed -i 's#include /etc/nginx/http.d/\*.conf;#include /config/nginx/site-confs/\*.conf;#g' /etc/nginx/nginx.conf && \
    printf '\n\npid /run/nginx/nginx.pid;\n\n' >> /etc/nginx/nginx.conf && \
  echo "**** fix logrotate ****" && \
    find /etc/logrotate.d \( -name nginx -o -name "php-fpm?" \) -exec echo rm {} \;  -exec rm {} \;

# add local files
COPY root-fs/ /

# Rootless Docker can't bind to 80 and 443 as they are smaller than 1024
EXPOSE 8080 8443 9000
