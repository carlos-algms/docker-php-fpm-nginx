ARG MYAPP_IMAGE=php:5.6-fpm
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


ARG PECL_EXT
RUN pecl install $PECL_EXT

ARG PHP_EXT
RUN docker-php-ext-install $PHP_EXT

ARG ENABLE_EXT
RUN docker-php-ext-enable $ENABLE_EXT

COPY ["nginx.conf", "/etc/nginx/conf.d/default.conf"]
COPY ["xdebug.ini", "/usr/local/etc/php/conf.d/"]
COPY ["php.ini", "/usr/local/etc/php/conf.d/"]

RUN php-fpm --daemonize --allow-to-run-as-root

CMD ["nginx"]
