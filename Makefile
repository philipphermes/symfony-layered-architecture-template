# Makefile
.PHONY: help dev-up dev-down dev-build prod-up prod-down prod-build

# Detect OS
ifeq ($(OS),Windows_NT)
    DETECTED_OS := Windows
    export USER_ID=1000
    export GROUP_ID=1000
else
    DETECTED_OS := $(shell uname -s)
    export USER_ID=$(shell id -u)
    export GROUP_ID=$(shell id -g)
endif

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

dev-build: ## Build development environment
	@echo "Building for $(DETECTED_OS) with UID=$(USER_ID) GID=$(GROUP_ID)"
	docker-compose build

dev-up: ## Start development environment
	@echo "Starting development environment on $(DETECTED_OS)"
	docker-compose up -d

dev-down: ## Stop development environment
	docker-compose down

dev-logs: ## View logs
	docker-compose logs -f app

dev-shell: ## Access container shell
	docker-compose exec app sh

composer-install: ## Install composer dependencies
	docker-compose exec app composer install

prod-build: ## Build production environment
	docker-compose -f docker-compose.prod.yml build

prod-up: ## Start production environment
	docker-compose -f docker-compose.prod.yml up -d

prod-down: ## Stop production environment
	docker-compose -f docker-compose.prod.yml down
