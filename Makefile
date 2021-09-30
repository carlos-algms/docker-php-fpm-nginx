IMAGE=carlosalgms/docker-php-fpm-nginx

build: TAG=7-fpm
build:
	docker build --rm \
		-t $(IMAGE):$(TAG) \
		-f Dockerfile \
		--build-arg FROM_IMAGE=php:$(TAG) \
		.


build_71: TAG=7.1-fpm
# xdebug 2.9.8 is the last version supporting php 7.1
build_71: PECL_EXT=xdebug-2.9.8 imagick-3.5.1
build_71: ENABLE_EXT=xdebug imagick
build_71: PHP_EXT=gd mysqli pdo_mysql opcache pspell mcrypt bcmath exif zip
build_71:
	docker build --rm \
		-t $(IMAGE):$(TAG) \
		-f Dockerfile \
		--build-arg FROM_IMAGE=php:$(TAG) \
		--build-arg PECL_EXT="$(PECL_EXT)" \
		--build-arg PHP_EXT="$(PHP_EXT)" \
		--build-arg ENABLE_EXT="$(ENABLE_EXT)" \
		.


# xdebug 2.5.5 is the last version supporting php 5.6
build_5: PECL_EXT=xdebug-2.5.5 imagick-3.4.4
build_5: PHP_EXT=gd mysql mysqli pdo_mysql opcache pspell mcrypt bcmath exif zip
build_5: ENABLE_EXT=xdebug mcrypt imagick
build_5: TAG=5.6-fpm
build_5:
	docker build --rm \
		-t $(IMAGE):$(TAG) \
		-f Dockerfile \
		--build-arg FROM_IMAGE=php:$(TAG) \
		--build-arg PECL_EXT="$(PECL_EXT)" \
		--build-arg PHP_EXT="$(PHP_EXT)" \
		--build-arg ENABLE_EXT="$(ENABLE_EXT)" \
		.


publish:
	docker push carlosalgms/docker-php-fpm-nginx:7-fpm

publish_71:
	docker push carlosalgms/docker-php-fpm-nginx:7.1-fpm

publish_5:
	docker push carlosalgms/docker-php-fpm-nginx:5.6-fpm



.PHONY: build build_71 build_5 publish publish_71 publish_5
