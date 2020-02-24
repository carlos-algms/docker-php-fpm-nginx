ARG MYAPP_IMAGE=php:7-fpm
FROM $MYAPP_IMAGE

LABEL maintainer="Carlos A. Gomes <carlos.algms@gmail.com>"

RUN apt-get update && apt-get install -y --no-install-recommends \
		aspell \
		libfreetype6-dev \
		libjpeg62-turbo-dev \
		libmagickwand-dev \
		libmcrypt-dev \
		libpng-dev \
		libpspell-dev \
		libxml2-dev \
		libzip-dev \
		nginx \
	&& rm -rf /var/cache/debconf/*-old \
	&& rm -rf /usr/share/doc/* \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /var/cache/apt/*


ARG PECL_EXT="xdebug-2.9.2 mcrypt-1.0.3 imagick-3.4.4"
RUN pecl install $PECL_EXT

ARG PHP_EXT="gd mysqli pdo_mysql opcache pspell bcmath exif zip"

RUN docker-php-ext-configure gd --with-freetype-dir=/usr --with-jpeg-dir=/usr --with-png-dir=/usr; \
		docker-php-ext-install -j "$(nproc)" $PHP_EXT

ARG ENABLE_EXT="xdebug mcrypt imagick"
RUN docker-php-ext-enable $ENABLE_EXT

COPY ["nginx.conf", "/etc/nginx/sites-available/default"]
COPY ["xdebug.ini", "/usr/local/etc/php/conf.d/"]
COPY ["php.ini", "/usr/local/etc/php/conf.d/"]
COPY ["run-nginx-with-php.sh", "/"]

RUN chmod +x /run-nginx-with-php.sh

CMD ["/run-nginx-with-php.sh"]
