ARG MYAPP_IMAGE=php:7-fpm
FROM $MYAPP_IMAGE

LABEL maintainer="Carlos A. Gomes <carlos.algms@gmail.com>"

RUN apt-get update && apt-get install -y \
		libfreetype6-dev \
		libjpeg62-turbo-dev \
		libpng-dev \
		libmcrypt-dev \
		libpspell-dev \
		libxml2-dev \
		aspell \
		nginx \
	&& rm -rf /var/cache/debconf/*-old \
	&& rm -rf /usr/share/doc/* \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /var/cache/apt/*


ARG PECL_EXT="xdebug-2.9.2 mcrypt-1.0.3"
RUN pecl install $PECL_EXT

ARG PHP_EXT="gd mysqli pdo_mysql opcache pspell xml"
RUN docker-php-ext-install $PHP_EXT

ARG ENABLE_EXT="${PHP_EXT} xdebug mcrypt"
RUN docker-php-ext-enable $ENABLE_EXT

COPY ["nginx.conf", "/etc/nginx/sites-available/default"]
COPY ["xdebug.ini", "/usr/local/etc/php/conf.d/"]
COPY ["php.ini", "/usr/local/etc/php/conf.d/"]
COPY ["cmd.sh", "/"]

RUN chmod +x /cmd.sh

CMD ["/cmd.sh"]
