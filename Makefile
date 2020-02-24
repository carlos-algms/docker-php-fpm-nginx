IMAGE=carlosalgms/docker-php-fpm-nginx

build_5: XDEBUG_VER=2.5.5
build_5: PHP_EXT=gd mysql mysqli pdo_mysql opcache pspell xml mcrypt
build_5: PECL_EXT=xdebug-$(XDEBUG_VER)
build_5: ENABLE_EXT=$(PHP_EXT) xdebug mcrypt
build_5: TAG=5.6-fpm
build_5:
	docker build --rm \
		-t $(IMAGE):$(TAG) \
		-f Dockerfile \
		--build-arg MYAPP_IMAGE=php:$(TAG) \
		--build-arg PHP_EXT="$(PHP_EXT)" \
		--build-arg PECL_EXT="$(PECL_EXT)" \
		--build-arg ENABLE_EXT="$(ENABLE_EXT)" \


build: TAG=7-fpm
build:
	docker build --rm \
		-t $(IMAGE):$(TAG) \
		-f Dockerfile \
		--build-arg MYAPP_IMAGE=php:$(TAG) \
		.
