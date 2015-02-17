PROJECT=cli

BUILD_PATH := $(shell pwd)/.gobuild
RELEASE_PATH := $(shell pwd)/release
ORG_PATH := $(BUILD_PATH)/src/github.com/ewoutp

BIN=helloworld

VERSION := $(shell cat VERSION)
COMMIT := $(shell git rev-parse HEAD | cut -c1-10)

.PHONY: clean deps 

GOPATH := $(BUILD_PATH)

SOURCE=$(shell find . -name '*.go')

ifndef GOOS
	GOOS := $(shell go env GOOS)
endif
ifndef GOARCH
	GOARCH := $(shell go env GOARCH)
endif

all: get-deps $(BIN)

clean:
	rm -rf $(BUILD_PATH) $(BIN) 

get-deps: .gobuild

deps:
	@${MAKE} -B -s .gobuild

.gobuild:
	@mkdir -p $(ORG_PATH)
	@rm -f $(ORG_PATH)/$(PROJECT) && cd "$(ORG_PATH)" && ln -s ../../../.. $(PROJECT)
	#
	# Fetch private packages first (so `go get` skips them later)

	#
	# Fetch public dependencies via `go get`
	GOPATH=$(GOPATH) go get -d -v github.com/ewoutp/$(PROJECT)

$(BIN): VERSION $(SOURCE)
	echo Building for $(GOOS)/$(GOARCH)
	docker run \
	    --rm \
	    -v $(shell pwd):/usr/code \
	    -e GOPATH=/usr/code/.gobuild \
	    -e GOOS=$(GOOS) \
	    -e GOARCH=$(GOARCH) \
	    -w /usr/code \
	    golang:1.3.1-cross \
	    go build -a -ldflags "-X main.projectVersion $(VERSION) -X main.projectBuild $(COMMIT)" -o $(BIN)

run-tests:
	GOPATH=$(GOPATH) go test ./...

