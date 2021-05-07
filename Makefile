.ONESHELL:

PLATFORMS := linux
ARCHITECTURES := amd64 arm64
BINARIES := tpm_attestor_server tpm_attestor_agent get_tpm_pubhash

DOCKER_PLATFORMS := $(foreach platform, $(PLATFORMS), $(foreach architecture, $(ARCHITECTURES), --platform $(platform)/$(architecture)))

BUILDS := $(foreach platform, $(PLATFORMS), $(foreach architecture, $(ARCHITECTURES), $(foreach binary, $(BINARIES), $(platform)-$(architecture)-$(binary))))
RELEASES := $(foreach build, $(BUILDS), $(build)-release)
DOCKER_IMAGES := $(foreach binary, $(BINARIES), $(binary)-docker)

target_words = $(subst -, ,$@)
target_platform = $(word 1, $(target_words))
target_architecture = $(word 2, $(target_words))
target_binary = $(word 3, $(target_words))
target_binary_hyphens = $(subst _,-,$(target_binary))

target_docker_binary = $(word 1, $(target_words))
target_docker_binary_hyphens = $(subst _,-,$(target_docker_binary))

REGISTRY ?= docker.io
VERSION ?= develop

build: $(BUILDS)
$(BUILDS):
	CGO_ENABLED=0 GOOS=$(target_platform) GOARCH=$(target_architecture) go build -ldflags="-s -w" -o build/$(target_platform)/$(target_architecture)/$(target_binary) cmd/$(target_binary)/main.go

test:
	go test ./...

release: $(RELEASES)
$(RELEASES):
	tar --owner=root --group=root -cvzf releases/$(target_platform)/$(target_architecture)/spire-tpm-plugin-$(target_binary_hyphens)-$(target_platform)-$(target_architecture).tar.gz -C build/$(target_platform)/$(target_architecture) $(target_binary)

docker: $(DOCKER_IMAGES)
$(DOCKER_IMAGES):
	docker buildx build $(DOCKER_PLATFORMS) --build-arg version=$(VERSION) --build-arg binary=$(target_docker_binary) -t $(REGISTRY)/spire-tpm-plugin-$(target_docker_binary_hyphens):$(VERSION) .

clean:
	rm -rf build releases

.PHONY: $(BUILDS) $(RELEASES) $($(DOCKER_IMAGES)) build test release docker clean
