all: help

.DEFAULT_GOAL := help

TARGET="service"
VERSION := $(shell git describe --abbrev=0 --tags ${TAG_COMMIT} 2>/dev/null || true)
BUILD := $(shell git rev-parse --short HEAD)
ifeq ($(VERSION),)
	VERSION := "dev"
endif
ifneq ($(shell git status --porcelain),)
	VERSION := $(VERSION)-dev
endif

FLAGS := -ldflags "-X=main.VERSION=$(VERSION) -X=main.BUILD=$(BUILD)"

# declare local env variables for development
include .env
export

help: ## shows this help
	@cat $(MAKEFILE_LIST) | grep -E '^[a-zA-Z_-]+:.*?## .*$$' | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

lint: ## Lint project
	@echo Adjust formatting...
	@find . -name '*.go' -type f -exec gofumpt -w {} \;
	golangci-lint run ./...

test-coverage: ## check coverage in default browser
	go test -coverprofile cover.out ./...
	go tool cover -html=cover.out

test: ## runs short tests
	go test -v -count=1 ./...

test-race: ## test with race detector
	go test -race -count=1 ./...

run: ## run development
	@go run $(FLAGS) cmd/service/main.go

build: ## build current
	go build $(FLAGS) -o bin/$(TARGET) cmd/service/main.go
