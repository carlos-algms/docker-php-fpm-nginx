IMAGE=carlosalgms/docker-php-fpm-nginx

build: XDEBUG_VER=2.5.5
build: PHP_EXT=gd mysql mysqli pdo_mysql opcache pspell xml mcrypt
build: PECL_EXT=xdebug-$(XDEBUG_VER)
build: ENABLE_EXT=$(PHP_EXT) xdebug mcrypt
build: TAG=5.6-fpm
build: _build


build_7: XDEBUG_VER=2.9.2
build_7: PHP_EXT=gd mysqli pdo_mysql opcache pspell xml
build_7: PECL_EXT=xdebug-$(XDEBUG_VER) mcrypt-1.0.3
build_7: ENABLE_EXT=$(PHP_EXT) xdebug mcrypt
build_7: TAG=7-fpm
build_7: _build


_build:
	docker build --rm \
		-t $(IMAGE):$(TAG) \
		-f Dockerfile \
		--build-arg MYAPP_IMAGE=php:$(TAG) \
		--build-arg PHP_EXT="$(PHP_EXT)" \
		--build-arg PECL_EXT="$(PECL_EXT)" \
		--build-arg ENABLE_EXT="$(ENABLE_EXT)" \
		.
