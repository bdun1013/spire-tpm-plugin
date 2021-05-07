.ONESHELL:

PLATFORMS := linux darwin
ARCHITECTURES := amd64 arm64
BINARIES := tpm_attestor_server tpm_attestor_agent get_tpm_pubhash

RELEASES := $(foreach platform, $(PLATFORMS), $(foreach architecture, $(ARCHITECTURES), $(foreach binary, $(BINARIES), $(platform)-$(architecture)-$(binary))))
RELEASE_ARCHIVES := $(foreach release, $(RELEASES), $(release)-archive)

USER := $(shell id -u)
GROUP := $(shell id -g)

target_words = $(subst -, ,$@)
target_platform = $(word 1, $(target_words))
target_architecture = $(word 2, $(target_words))
target_binary = $(word 3, $(target_words))
target_binary_hyphens = $(subst _,-,$(target_binary))

release: $(RELEASES)
$(RELEASES):
	CGO_ENABLED=0 GOOS=$(target_platform) GOARCH=$(target_architecture) go build -o releases/$(target_platform)/$(target_architecture)/$(target_binary) cmd/$(target_binary)/main.go

test:
	go test ./...

package: $(RELEASE_ARCHIVES)
$(RELEASE_ARCHIVES): clean-archives
	sudo chown root:root releases/$(target_platform)/$(target_architecture)/$(target_binary)
	tar -cvzf releases/$(target_platform)/$(target_architecture)/$(target_binary_hyphens)-$(target_platform)-$(target_architecture).tar.gz -C releases/$(target_platform)/$(target_architecture) $(target_binary)
	sudo chown $(USER):$(GROUP) releases/$(target_platform)/$(target_architecture)/$(target_binary)

clean-archives:
	rm -rf releases/**/*.tar.gz

clean:
	rm -rf releases

.PHONY: $(RELEASES) release test clean

