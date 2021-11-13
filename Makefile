IMAGE=carlosalgms/docker-php-fpm-nginx

LATEST=8
TAG?=$(LATEST)
XDEBUG_VERSION?=3.1.1
BASE_EXT=gd mysqli pdo_mysql opcache pspell bcmath exif zip pcntl

# Cache the previous build to leverage Docker's layer feature
# https://andrewlock.net/caching-docker-layers-on-serverless-build-hosts-with-multi-stage-builds---target,-and---cache-from/

define BASE_BUILD
docker pull $(IMAGE):$(TAG) || true; \
docker pull $(IMAGE):$(TAG)-xdebug || true; \
docker build --rm . \
	--cache-from $(IMAGE):$(TAG) \
	-t $(IMAGE):$(TAG) \
	-f Dockerfile \
	--build-arg FROM_IMAGE=php:$(TAG)-fpm
endef


define BUILD_WITH_ARGS
$(BASE_BUILD) \
	--build-arg PECL_EXT="$(PECL_EXT)" \
	--build-arg ENABLE_EXT="$(ENABLE_EXT)" \
	--build-arg PHP_EXT="$(PHP_EXT)"
endef


define BUILD_XDEBUG
docker build --rm . \
	--cache-from $(IMAGE):$(TAG)-xdebug \
	-t $(IMAGE):$(TAG)-xdebug \
	-f Dockerfile.xdebug \
	--build-arg PECL_EXT="xdebug-$(XDEBUG_VERSION)" \
	--build-arg FROM_IMAGE=$(IMAGE):$(TAG)
endef



build:
	$(BASE_BUILD)
	$(BUILD_XDEBUG)


build_7: TAG:=7
build_7: XDEBUG_VERSION:=3.0.4
build_7: build


build_71: TAG=7.1
build_71: PECL_EXT=imagick-3.5.1
build_71: ENABLE_EXT=imagick
build_71: PHP_EXT:=$(BASE_EXT) mcrypt
build_71: XDEBUG_VERSION=2.9.8
build_71:
	$(BUILD_WITH_ARGS)
	$(BUILD_XDEBUG)


build_5: TAG=5.6
build_5: VARIABLE_LIBS=libmagickwand-6.q16-3
build_5: PECL_EXT=imagick-3.4.4
build_5: ENABLE_EXT=imagick
build_5: GD_CONFIG=--with-freetype-dir=/usr --with-jpeg-dir=/usr --with-png-dir=/usr
build_5: PHP_EXT=$(BASE_EXT) mcrypt mysql
build_5: XDEBUG_VERSION=2.5.5
build_5:
	$(BUILD_WITH_ARGS) \
		--build-arg GD_CONFIG="$(GD_CONFIG)" \
		--build-arg VARIABLE_LIBS="$(VARIABLE_LIBS)"
	$(BUILD_XDEBUG)


publish:
	docker push $(IMAGE):$(TAG)
	docker push $(IMAGE):$(TAG)-xdebug
	if [ "$(TAG)" = "$(LATEST)" ]; then \
		( docker tag $(IMAGE):$(TAG) $(IMAGE):latest \
		&& docker push $(IMAGE):latest ) \
	fi


.PHONY: build build_7 build_71 build_5 publish pull_for_cache
