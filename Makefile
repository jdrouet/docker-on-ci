BUILDX_VER=v0.3.0
APP_VER=v0.8.0
CI_NAME?=local
IMAGE_NAME=jdrouet/docker-on-ci
VERSION?=latest

before-install:
	mkdir -vp ~/.docker/cli-plugins/ ~/dockercache

install-buildx: before-install
	curl --silent -L "https://github.com/docker/buildx/releases/download/${BUILDX_VER}/buildx-${BUILDX_VER}.linux-amd64" > ~/.docker/cli-plugins/docker-buildx
	chmod a+x ~/.docker/cli-plugins/docker-buildx
	docker buildx version

install-app: before-install
	curl -fsSL --output /tmp/docker-app-linux.tar.gz "https://github.com/docker/app/releases/download/${APP_VER}/docker-app-linux.tar.gz"
	tar xf /tmp/docker-app-linux.tar.gz -C /tmp/
	cp /tmp/docker-app-plugin-linux ~/.docker/cli-plugins/docker-app
	chmod a+x ~/.docker/cli-plugins/docker-app
	docker app version

prepare: install-buildx install-app
	docker buildx create --use

prepare-old: install-buildx install-app
	docker context create old-style
	docker buildx create old-style --use

build-push:
	docker buildx build --push \
		--build-arg CI_NAME=${CI_NAME} \
		--platform linux/arm/v7,linux/arm64/v8,linux/386,linux/amd64 \
		-t ${IMAGE_NAME}:server-${VERSION}-${CI_NAME} server
