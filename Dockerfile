ARG FROM_IMAGE=php:7-fpm
FROM $FROM_IMAGE

LABEL maintainer="Carlos A. Gomes <carlos.algms@gmail.com>"

RUN apt-get update && apt-get install -y --no-install-recommends \
		aspell \
		gettext-base \
		libfreetype6-dev \
		libjpeg62-turbo-dev \
		libmagickwand-dev \
		libmcrypt-dev \
		libpng-dev \
		libpspell-dev \
		libxml2-dev \
		libzip-dev \
		nginx \
		supervisor \
	&& rm -rf /var/cache/debconf/*-old \
	&& rm -rf /usr/share/doc/* \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /var/cache/apt/*


ARG PECL_EXT="xdebug-3.0.4 mcrypt-1.0.4 imagick-3.5.1"
RUN pecl install $PECL_EXT

ARG PHP_EXT="gd mysqli pdo_mysql opcache pspell bcmath exif zip"
RUN docker-php-ext-configure gd --with-freetype-dir=/usr --with-jpeg-dir=/usr --with-png-dir=/usr; \
	docker-php-ext-install -j "$(nproc)" $PHP_EXT

ARG ENABLE_EXT="xdebug mcrypt imagick"
RUN docker-php-ext-enable $ENABLE_EXT

# Add Tini
ADD https://github.com/krallin/tini/releases/download/v0.19.0/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini

ENTRYPOINT ["tini", "--"]

COPY ["default-site.conf", "/etc/nginx/sites-available/default"]
COPY ["snippets/*", "/etc/nginx/snippets/"]
COPY ["xdebug.ini", "/usr/local/etc/php/conf.d/"]
COPY ["php.ini", "/usr/local/etc/php/conf.d/"]
COPY ["php-nginx-supervisor.conf", "/etc/supervisor/conf.d/"]
COPY ["php-fpm-log.conf", "/usr/local/etc/php-fpm.d/"]

CMD export ROOT_PATH=${ROOT_PATH:-/var/www/html} && \
	envsubst < /etc/nginx/snippets/root.conf.template > /etc/nginx/snippets/root.conf && \
	/usr/bin/supervisord -c /etc/supervisor/supervisord.conf -n
