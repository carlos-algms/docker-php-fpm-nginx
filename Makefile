IMAGE=carlosalgms/docker-php-fpm-nginx

PHP_VER?=8
LATEST=$(PHP_VER)-alpine
TAG?=$(LATEST)
FROM_IMAGE?=alpine:3.16
EXTRA_REPO?=""
VARIABLE_DEPS?=""
XDEBUG_PKG?="php$(PHP_VER)-pecl-xdebug"


# Cache the previous build to leverage Docker's layer feature
# https://andrewlock.net/caching-docker-layers-on-serverless-build-hosts-with-multi-stage-builds---target,-and---cache-from/

define BASE_BUILD
docker pull $(IMAGE):$(TAG) || true; \
docker buildx build --rm . \
	--cache-from $(IMAGE):$(TAG) \
	--cache-to type=inline \
	-t $(IMAGE):$(TAG) \
	--build-arg VERSION=$(TAG) \
	--build-arg BUILD_DATE="$(shell date)" \
	--build-arg FROM_IMAGE=$(FROM_IMAGE) \
	--build-arg PHP_VER="$(PHP_VER)" \
	--build-arg VARIABLE_DEPS="$(VARIABLE_DEPS)" \
	--build-arg EXTRA_REPO="$(EXTRA_REPO)" \
	-f Dockerfile
endef



define BUILD_XDEBUG
docker pull $(IMAGE):$(TAG)-xdebug || true; \
docker buildx build --rm . \
	--cache-from $(IMAGE):$(TAG)-xdebug \
	--cache-to type=inline \
	-t $(IMAGE):$(TAG)-xdebug \
	--build-arg VERSION=$(TAG)-xdebug \
	--build-arg BUILD_DATE="$(shell date)" \
	--build-arg FROM_IMAGE=$(IMAGE):$(TAG) \
	--build-arg XDEBUG_PKG=$(XDEBUG_PKG) \
	-f Dockerfile.xdebug
endef



build:
	$(BASE_BUILD)
	$(BUILD_XDEBUG)

## https://pkgs.alpinelinux.org/packages
### Alpine 3.15 is the last one with php7 available
build_7: TAG:=7-alpine
build_7: PHP_VER:=7
build_7: EXTRA_REPO:=3.15
build_7: build


### Alpine 3.7 is the last one with php7.1 available, check if is it safe to use higher PHP versions on my Apps
build_71: TAG:=7.1-alpine
build_71: PHP_VER:=7
build_71: EXTRA_REPO:=3.7
build_71: VARIABLE_DEPS:=php7-mcrypt php7-imagick
build_71: XDEBUG_PKG:="php7-xdebug"
build_71: build


### Alpine 3.8 is the last one with php5.6 available
build_5: TAG:=5.6-alpine
build_5: EXTRA_REPO:=3.8
build_5: VARIABLE_DEPS:=php5-mcrypt php5-imagick
build_5: PHP_VER:=5
build_5: build


publish:
	docker push $(IMAGE):$(TAG)
	docker push $(IMAGE):$(TAG)-xdebug
	if [ "$(TAG)" = "$(LATEST)" ]; then \
		( docker tag $(IMAGE):$(TAG) $(IMAGE):latest \
		&& docker push $(IMAGE):latest ) \
	fi


.PHONY: build build_7 build_71 build_5 publish
