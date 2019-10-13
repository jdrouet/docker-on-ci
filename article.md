---
title: Multi arch images with docker
published: false
description:
tags:
  - docker
  - multiarch
  - ci
---

Most of the time, when I start a project, I like to try to install it everywhere to test it. Since I have a cluster of Raspberry PIs, I love to install my projects on it and see how they evolve, where they could break and fix the issues.

To do so, I try to get as close a possible to my production configuration. So I usually put in place a CI/CD that test, build and deploy my projects. But when it comes to build my Docker Images for ARMv7 on a regular CI, it tends to become a bit complicated. You need to have Qemu available on the CI to emulate the target platform.

```bash
# depending on the CI
docker run --rm --privileged hypriot/qemu-register
# or
docker run --rm --privileged multiarch/qemu-user-static:register --reset
```

When this is done, I also want to try the image on my laptop. So, on the CI, we have to build for different architecture with the same Dockerfile.

One way to do it would be to have and argument in our Dockerfile to specify the platform.

```dockerfile
ARG BASE_ARCH=amd64
FROM ${BASE_ARCH}/alpine
```

Once this is done, I "just" have to build several times on my favorite CI, create a [manifest](https://docs.docker.com/engine/reference/commandline/manifest/) and annotate each image in a final stage.

```bash
docker build --build-arg BASE_ARCH=amd64 -t my_image:amd64-latest .
docker build --build-arg BASE_ARCH=arm32v7 -t my_image:arm32v7-latest .
docker manifest create my_image:latest my_image:amd64-latest my_image:arm32v7-latest
docker manifest annotate --arch amd64 my_image:latest my_image:amd64-latest
docker manifest annotate --arch armv7 my_image:latest my_image:arm32v7-latest
```

Ok, you can say it, it's pretty verbose.

Luckily, the Docker Team (relatively) recently released [buildx](https://github.com/docker/buildx) in Tech Preview. What this does is that it will build all the images, do the manifest and annotate everything in only 1 command.

First we have to remove the argument from our dockerfile because it became useless. If we create an image from a multiarch image, buildx will manage the rest.

```bash
docker buildx build --platform linux/arm/v7,linux/amd64 -t my_image:latest .
```

At this point, I can use the image on any of the 2 platforms without having to use different images.

Ok, now this is nice but buildx is only available in experimental and requires Docker Engine 18.09+. And depending on the CI that is going to be used, the installation will more or less differ. So I prepared [a repository](https://github.com/jdrouet/docker-on-ci/) containing an example of multi arch build with [Github Actions](https://github.com/features/actions), [Circle CI](https://circleci.com/), [Travis CI](https://travis-ci.org/) and [Gitlab CI](https://about.gitlab.com/product/continuous-integration/).
