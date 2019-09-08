# Makefile creates docker images and pushes it to DockerHub Registry

VPATH = src/ui src/comment monitoring/prometheus

# User name used to login Docker registry
export USER_NAME ?= ivbdockerhub
DOCKER_REPO ?= $(USER_NAME)

# Search for Dockerfile location
DOCKERFILES = $(shell find * -type f -name Dockerfile)
DOCKERSDIRS=$(subst /,\:,$(subst /Dockerfile,,$(DOCKERFILES)))
# version for created images
VER = latest
# VER = $(shell cat $DOCKERFILES/VERSION)  comment post-py  img:  img_comment img_post-py

REDDIT_SERVICES = ui comment post-py
REDDIT_IMAGES = img_ui img_comment img_post-py
MON_SERVICES = prometheus mongodb_exporter blackbox_exporter
#MON_SERVICES = $(shell for i in $$MON_SUBDIRS ; do basename $$i ; done)
MON_IMAGES = img_prometheus img_mongodb_exporter img_blackbox_exporter

# mapping to the monitoring services
MON_prometheus_DIR = monitoring/prometheus
MON_mongodb_exporter_DIR = monitoring/exporters/mongodb_exporter
MON_blackbox_exporter_DIR = monitoring/exporters/blackbox_exporter

#DOCKER_IMAGE_TAG        ?= $(subst /,-,$(shell git rev-parse --abbrev-ref HEAD))
#DOCKERFILE_PATH         ?= ./Dockerfile

# HELP 
.PHONY: help
help: ## This help.
	@echo 'Never run this Makefile for your own safety!!!'


all: img_build img_push
img_push: img_build  ## img_push cannot be handled until img_build is completed
.PHONY: all

img_build: microservices monitoring debug

.PHONY: debug
debug: ## Display current var's values
	@echo "$$(date +"%Y-%m-%d %H:%M:%S") DockerHub: $(DOCKER_REPO)" >> /tmp/make_info.log
	@echo "$$(date +"%Y-%m-%d %H:%M:%S") DOCKERFILES: $(DOCKERFILES)" >> /tmp/make_info.log
	@echo "$$(date +"%Y-%m-%d %H:%M:%S") Docker's Dirs: $(DOCKERSDIRS)" >>/tmp/make_info.log 
	@echo "$$(date +"%Y-%m-%d %H:%M:%S") MonServices: $(MON_SERVICES)" >> /tmp/make_info.log
	@echo "=============================================================" >> /tmp/make_info.log

# microservices: post comment ui
# Docker build reddit's microservice images using recursive Make:
# ---------------------------------------------------------------
.PHONY: microservices $(REDDIT_SERVICES)
microservices: $(REDDIT_SERVICES)
$(REDDIT_SERVICES):
	$(MAKE) -w -C src/$@
	

# BUILD monitoring service images:
# --------------------------------
.PHONY: monitoring $(MON_SERVICES)
monitoring: $(MON_SERVICES)
$(MON_SERVICES):
	@echo "$(date +"%Y-%m-%d %H:%M:%S") build $(DOCKER_REPO)/$@:$$VER" >> /tmp/make_info.log
	cd $(MON_$@_DIR) && docker build . -t $(DOCKER_REPO)/$@:$(VER)

#-------------------------------------------
# Let's PUSH them(images) to the Docker Hub:
# ------------------------------------------
all-push: push-microservices push-monitoring dockerhub-login
.PHONY: all-push

# Loging to the Docker Registry
.PHONY: dockerhub-login
dockerhub-login: ## Login to DockerHub
	docker login

# Push microservice images to the Docker Registry:
.PHONY: push-microservices $(REDDIT_SERVICES) 
push-microservices: $(REDDIT_IMAGES) dockerhub-login
$(REDDIT_IMAGES):
	@echo "$(date +"%Y-%m-%d %H:%M:%S") push $(DOCKER_REPO)/$(subst img_,,$@):$$VER" >> /tmp/make_info.log
	docker push $(DOCKER_REPO)/$(subst img_,,$@):$(VER) 
	
# Push monitoring images to the Docker Registry:
.PHONY: push-monitoring $(MON_SERVICES) 
push-monitoring: $(MON_IMAGES) dockerhub-login
$(MON_IMAGES):
	@echo "$(date +"%Y-%m-%d %H:%M:%S") push $(DOCKER_REPO)/$(subst img_,,$@):$$VER" >> /tmp/make_info.log
	docker push $(DOCKER_REPO)/$(subst img_,,$@):$(VER)

.PHONY: clean 
clean:
	rm -rf *.tmp
