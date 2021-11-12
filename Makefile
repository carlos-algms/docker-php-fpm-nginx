IMAGE=carlosalgms/docker-php-fpm-nginx

# TODO verify the extensions versions working with PHP 8
build: TAG=8
build:
	docker build --rm . \
		-t $(IMAGE):$(TAG) \
		-t $(IMAGE):latest \
		-f Dockerfile \
		--build-arg FROM_IMAGE=php:$(TAG)-fpm

	docker build --rm . \
		-t $(IMAGE):$(TAG)-xdebug \
		-t $(IMAGE):latest-xdebug \
		-f Dockerfile.xdebug \
		--build-arg PECL_EXT="xdebug-3.1.1" \
		--build-arg FROM_IMAGE=$(IMAGE):$(TAG)

build_7: TAG=7
build_7:
	docker build --rm . \
		-t $(IMAGE):$(TAG) \
		-f Dockerfile \
		--build-arg FROM_IMAGE=php:$(TAG)-fpm

	docker build --rm . \
		-t $(IMAGE):$(TAG)-xdebug \
		-f Dockerfile.xdebug \
		--build-arg PECL_EXT="xdebug-3.0.4" \
		--build-arg FROM_IMAGE=$(IMAGE):$(TAG)


build_71: TAG=7.1
# xdebug 2.9.8 is the last version supporting php 7.1
build_71: PECL_EXT=imagick-3.5.1
build_71: ENABLE_EXT=imagick
build_71: PHP_EXT=gd mysqli pdo_mysql opcache pspell bcmath exif zip pcntl mcrypt
build_71:
	docker build --rm . \
		-t $(IMAGE):$(TAG) \
		-f Dockerfile \
		--build-arg FROM_IMAGE=php:$(TAG)-fpm \
		--build-arg PECL_EXT="$(PECL_EXT)" \
		--build-arg PHP_EXT="$(PHP_EXT)" \
		--build-arg ENABLE_EXT="$(ENABLE_EXT)" \

	docker build --rm . \
		-t $(IMAGE):$(TAG)-xdebug \
		-f Dockerfile.xdebug \
		--build-arg PECL_EXT="xdebug-2.9.8" \
		--build-arg FROM_IMAGE=$(IMAGE):$(TAG)


build_5: TAG=5.6
build_5: PECL_EXT=imagick-3.4.4
build_5: PHP_EXT=gd mysqli pdo_mysql opcache pspell bcmath exif zip pcntl mcrypt mysql
build_5: ENABLE_EXT=xdebug mcrypt imagick
build_5:
	docker build --rm . \
		-t $(IMAGE):$(TAG) \
		-f Dockerfile \
		--build-arg FROM_IMAGE=php:$(TAG)-fpm \
		--build-arg PECL_EXT="$(PECL_EXT)" \
		--build-arg PHP_EXT="$(PHP_EXT)" \
		--build-arg ENABLE_EXT="$(ENABLE_EXT)" \

	docker build --rm . \
		-t $(IMAGE):$(TAG)-xdebug \
		-f Dockerfile.xdebug \
		--build-arg PECL_EXT="xdebug-2.5.5" \
		--build-arg FROM_IMAGE=$(IMAGE):$(TAG)


publish:
	docker push carlosalgms/docker-php-fpm-nginx:8
	docker push carlosalgms/docker-php-fpm-nginx:8-xdebug

publish_7:
	docker push carlosalgms/docker-php-fpm-nginx:7
	docker push carlosalgms/docker-php-fpm-nginx:7-xdebug

publish_71:
	docker push carlosalgms/docker-php-fpm-nginx:7.1
	docker push carlosalgms/docker-php-fpm-nginx:7.1-xdebug

publish_5:
	docker push carlosalgms/docker-php-fpm-nginx:5.6
	docker push carlosalgms/docker-php-fpm-nginx:5.6-xdebug



.PHONY: build build_7 build_71 build_5 publish publish_7 publish_71 publish_5
