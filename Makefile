IMAGE=carlosalgms/docker-php-fpm-nginx

# xdebug 2.5.5 is the last version supporting php 5.6
build_5: PECL_EXT=xdebug-2.5.5 imagick-3.4.4
build_5: PHP_EXT=gd mysql mysqli pdo_mysql opcache pspell mcrypt bcmath exif zip
build_5: ENABLE_EXT=xdebug mcrypt imagick
build_5: TAG=5.6-fpm
build_5:
	docker build --rm \
		-t $(IMAGE):$(TAG) \
		-f Dockerfile \
		--build-arg MYAPP_IMAGE=php:$(TAG) \
		--build-arg PECL_EXT="$(PECL_EXT)" \
		--build-arg PHP_EXT="$(PHP_EXT)" \
		--build-arg ENABLE_EXT="$(ENABLE_EXT)" \
		.


build: TAG=7-fpm
build:
	docker build --rm \
		-t $(IMAGE):$(TAG) \
		-f Dockerfile \
		--build-arg MYAPP_IMAGE=php:$(TAG) \
		.

publish:
	docker push carlosalgms/docker-php-fpm-nginx:7-fpm

publish_5:
	docker push carlosalgms/docker-php-fpm-nginx:5.6-fpm
