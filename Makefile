PLATFORMS := linux darwin
ARCHITECTURES := amd64 arm64
BINARIES := tpm_attestor_server tpm_attestor_agent get_tpm_pubhash

RELEASES := $(foreach platform, $(PLATFORMS), $(foreach architecture, $(ARCHITECTURES), $(foreach binary, $(BINARIES), $(platform)/$(architecture)/$(binary))))

target = $(subst /, ,$@)
target_platform = $(word 1, $(target))
target_architecture = $(word 2, $(target))
target_binary = $(word 3, $(target))

release: $(RELEASES)

$(RELEASES):
	CGO_ENABLED=0 GOOS=$(target_platform) GOARCH=$(target_architecture) go build -o releases/$(target_platform)/$(target_architecture)/$(target_binary) cmd/$(target_binary).go

.PHONY: $(RELEASES) release

