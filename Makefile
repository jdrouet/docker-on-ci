BUILDX_VER=v0.3.0
CI_NAME?=local
IMAGE_NAME=jdrouet/docker-on-ci
VERSION?=latest

prepare:
	mkdir -vp ~/.docker/cli-plugins/ ~/dockercache
	curl --silent -L "https://github.com/docker/buildx/releases/download/${BUILDX_VER}/buildx-${BUILDX_VER}.linux-amd64" > ~/.docker/cli-plugins/docker-buildx
	chmod a+x ~/.docker/cli-plugins/docker-buildx
	docker buildx create --use

build-push:
	docker buildx build --push \
		--build-arg CI_NAME=${CI_NAME} \
		--platform linux/arm/v7,linux/arm64/v8,linux/386,linux/amd64 \
		-t ${IMAGE_NAME}:${VERSION}-${CI_NAME} .
