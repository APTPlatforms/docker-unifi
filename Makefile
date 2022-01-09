UNIFI_CONTROLLER_VERSION := 6.5.55

export DOCKER_BUILDKIT := 1

.PHONY: image
image:
	docker pull aptplatforms/unifi:latest
	docker pull debian:9-slim
	docker build --progress=plain \
		--build-arg BUILDKIT_INLINE_CACHE=1 \
		--build-arg UNIFI_CONTROLLER_VERSION=$(UNIFI_CONTROLLER_VERSION) \
		--cache-from aptplatforms/unifi:latest \
		--cache-from debian:9-slim \
		-t aptplatforms/unifi:latest \
		.
	docker tag aptplatforms/unifi:latest aptplatforms/unifi:$(UNIFI_CONTROLLER_VERSION)
