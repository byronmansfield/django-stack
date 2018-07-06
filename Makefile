BUILD_DATE ?= $(strip $(shell date -u +"%Y-%m-%dT%H:%M:%SZ"))
VERSION ?= $(shell cat VERSION)
VENDOR ?= bmansfield
PROJECT_NAME ?= django-stack
DOCKER_IMAGE ?= $(VENDOR)/$(PROJECT_NAME)
ENVIRONMENT ?= development
REGION ?= us-east-1
ENV_FILE ?= .env.export
EXPOSE_PORT ?= 8000
GIT_TAG ?= $(strip $(shell git rev-parse --abbrev-ref HEAD | tr '/' '-'))
GIT_COMMIT = $(strip $(shell git rev-parse --short HEAD))
GIT_URL ?= $(strip $(shell git config --get remote.origin.url))

# Find out if the working directory is clean
GIT_NOT_CLEAN_CHECK = $(shell git status --porcelain)

default: build

build: docker_build output

build_clean: docker_build_clean output

run: docker_run output

up: docker_compose_up output

down: docker_compose_down output

push: docker_push

docker_clean: docker_image_clean

clean: clean

clean_all: docker_image_clean docker_container_clean clean

tag: docker_tag

deploy: docker_build docker_tag docker_push output

ifeq ($(MAKECMDGOALS), deploy)

# Get the version number from the code
GIT_TAG = v$(strip $(shell cat GIT_TAG))

ifndef GIT_TAG
$(error You need to create a GIT_TAG file to deploy)
endif

# See what commit is tagged to match the version
GIT_TAG_COMMIT = $(strip $(shell git rev-list $(GIT_TAG) -n 1 | cut -c1-7))
ifneq ($(GIT_TAG_COMMIT), $(GIT_COMMIT))
$(error echo You are trying to push a build based on commit $(GIT_COMMIT) but the tagged release version is $(GIT_TAG_COMMIT))
endif

# Don't push to Docker Hub if this isn't a clean repo
ifneq (x$(GIT_NOT_CLEAN_CHECK), x)
$(error echo You are trying to release a build based on a dirty repo)
endif

endif

#Set DOCKER_TAG
DOCKER_TAG = $(GIT_TAG)-$(GIT_COMMIT)

docker_build:
	# Build Docker image
	docker build \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg VERSION="$(VERSION)" \
		--build-arg VCS_URL="$(GIT_URL)" \
		--build-arg VCS_REF="$(GIT_COMMIT)" \
		--build-arg REPO="$(PROJECT_NAME)" \
		--build-arg VENDOR="$(VENDOR)" \
		--build-arg BUILD_NUMBER="$(BUILD_NUMBER)" \
		--build-arg ENVIRONMENT="$(ENVIRONMENT)" \
		-t $(DOCKER_IMAGE):latest \
		-t $(DOCKER_IMAGE):$(DOCKER_TAG) .

docker_build_clean:
	# Build Docker image
	docker build \
		--no-cache \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg VERSION="$(VERSION)" \
		--build-arg VCS_URL="$(GIT_URL)" \
		--build-arg VCS_REF="$(GIT_COMMIT)" \
		--build-arg REPO="$(PROJECT_NAME)" \
		--build-arg VENDOR="$(VENDOR)" \
		--build-arg BUILD_NUMBER="$(BUILD_NUMBER)" \
		--build-arg ENVIRONMENT="$(ENVIRONMENT)" \
		-t $(DOCKER_IMAGE):latest \
		-t $(DOCKER_IMAGE):$(DOCKER_TAG) .

docker_run:
	# Run Docker container
	docker run \
		-it \
		-d \
		-p $(EXPOSE_PORT):$(EXPOSE_PORT) \
		--env-file $(ENV_FILE) \
		--name $(PROJECT_NAME) \
		-t $(DOCKER_IMAGE):$(DOCKER_TAG)

docker_tag:
	# Tag image as latest
	docker tag $(DOCKER_IMAGE):$(DOCKER_TAG) $(DOCKER_IMAGE):latest

docker_push:
	# Push to DockerHub
	docker push $(DOCKER_IMAGE):$(DOCKER_TAG)
	docker push $(DOCKER_IMAGE):latest

docker_image_clean:
	# cleans out all local images that failed
	docker rmi -f `docker images | grep "^<none>" | awk "{print $3}"`

docker_container_clean:
	# cleans out all local containers
	docker rm `docker ps -a -q`

docker_compose_up:
	docker-compose \
		up \
		-d

docker_compose_down:
	docker-compose \
		down

clean:
		# removes created env file
		rm $(ENV_FILE)

output:
		@echo Docker Image: $(DOCKER_IMAGE):$(DOCKER_TAG)
