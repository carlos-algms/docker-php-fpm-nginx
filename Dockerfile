ARG FROM_IMAGE=php:8-fpm
FROM $FROM_IMAGE

LABEL maintainer="Carlos A. Gomes <carlos.algms@gmail.com>"

RUN apt-get update \
	&& apt-get upgrade -y \
	&& apt-get install -y --no-install-recommends \
		zsh \
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
	&& apt-get clean \
	&& rm -rf /var/cache/debconf/*-old \
	&& rm -rf /usr/share/doc/* \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /var/cache/apt/* \
	&& ln -sfn /dev/stdout /var/log/nginx/access.log \
	&& ln -sfn /dev/stderr /var/log/nginx/error.log


ARG PECL_EXT="mcrypt-1.0.4 imagick-3.5.1"
RUN pecl install $PECL_EXT

ARG PHP_EXT="gd mysqli pdo_mysql opcache pspell bcmath exif zip pcntl"
RUN docker-php-ext-configure gd --with-freetype-dir=/usr --with-jpeg-dir=/usr --with-png-dir=/usr; \
	docker-php-ext-install -j "$(nproc)" $PHP_EXT

ARG ENABLE_EXT="mcrypt imagick"
RUN docker-php-ext-enable $ENABLE_EXT

RUN curl "https://getcomposer.org/installer" --output "composer-setup.php" && \
	php -r "if (hash_file('sha384', 'composer-setup.php') === '906a84df04cea2aa72f40b5f787e49f22d4c2f19492ac310e8cba5b96ac8b64115ac402c8cd292b8a03482574915d1a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; } echo PHP_EOL;" && \
	php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
	rm "composer-setup.php"

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
