# Makefile for Symfony Docker Environment
# Automatically detects OS and applies appropriate settings

.DEFAULT_GOAL := help
.PHONY: help init dev-build dev-up dev-down dev-restart dev-logs dev-shell composer-install cache-clear prod-build prod-up prod-down clean

# Colors for output (portable)
RED := $(shell printf '\033[0;31m')
GREEN := $(shell printf '\033[0;32m')
YELLOW := $(shell printf '\033[0;33m')
BLUE := $(shell printf '\033[0;36m')
MAGENTA := $(shell printf '\033[0;35m')
CYAN := $(shell printf '\033[0;36m')
WHITE := $(shell printf '\033[0;37m')
NC := $(shell printf '\033[0m') # No Color

# Detect OS
ifeq ($(OS),Windows_NT)
    DETECTED_OS := Windows
    SHELL := cmd
    RM := del /Q /F
    MKDIR := mkdir
    export USER_ID := 1000
    export GROUP_ID := 1000
    export VOLUME_FLAGS := cached
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
        DETECTED_OS := Linux
        export USER_ID := $(shell id -u)
        export GROUP_ID := $(shell id -g)
        export VOLUME_FLAGS :=
    endif
    ifeq ($(UNAME_S),Darwin)
        DETECTED_OS := macOS
        export USER_ID := 1000
        export GROUP_ID := 1000
        export VOLUME_FLAGS := cached
    endif
    SHELL := /bin/bash
    RM := rm -rf
    MKDIR := mkdir -p
endif


ENV ?= dev #dev, test or prod
DOCKER_COMPOSE_FILE = docker-compose.$(ENV).yaml
DOCKER_COMPOSE = docker compose -f $(DOCKER_COMPOSE_FILE)

# Project name
PROJECT_NAME := symfony-app

##@ Help

help: ## Display this help message
	@echo "$(BLUE)Symfony Docker Environment$(NC)"
	@echo "$(YELLOW)Detected OS: $(DETECTED_OS)$(NC)"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf "Usage:\n  make $(BLUE)<target>$(NC)\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  $(BLUE)%-20s$(NC) %s\n", $$1, $$2 } /^##@/ { printf "\n$(YELLOW)%s$(NC)\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Setup

init: ## Initialize project (first time setup)
	@echo "$(GREEN)Initializing project for $(DETECTED_OS)...$(NC)"
	@if [ ! -f .env ]; then \
		echo "$(YELLOW)Creating .env file from .env.dist...$(NC)"; \
		cp .env.dist .env; \
		echo "USER_ID=$(USER_ID)" >> .env; \
		echo "GROUP_ID=$(GROUP_ID)" >> .env; \
		echo "VOLUME_FLAGS=$(VOLUME_FLAGS)" >> .env; \
		echo "$(GREEN).env file created with OS-specific settings$(NC)"; \
	else \
		echo "$(YELLOW).env file already exists, skipping...$(NC)"; \
	fi
	@echo "$(GREEN)Initialization complete!$(NC)"
	@echo "$(BLUE)Run 'make dev-build' to build the containers$(NC)"

build: ## Build containers
	@echo "$(GREEN)Building containers for $(DETECTED_OS)...$(NC)"
	@echo "$(YELLOW)USER_ID=$(USER_ID) GROUP_ID=$(GROUP_ID)$(NC)"
	$(DOCKER_COMPOSE) build --build-arg USER_ID=$(USER_ID) --build-arg GROUP_ID=$(GROUP_ID)
	@echo "$(GREEN)Build complete!$(NC)"

up: ## Start environment
	@echo "$(GREEN)Starting environment on $(DETECTED_OS)...$(NC)"
	$(DOCKER_COMPOSE) up -d
	@echo ""
	@echo "$(GREEN)Environment is running!$(NC)"
	@echo "$(BLUE)Application: http://localhost:8080$(NC)"
	@echo "$(BLUE)Database:    localhost:5432$(NC)"
	@echo "$(BLUE)Health:      http://localhost:8080/health$(NC)"
	@echo ""
	@echo "Run '$(YELLOW)make logs$(NC)' to view logs"

down: ## Stop environment
	@echo "$(YELLOW)Stopping environment...$(NC)"
	$(DOCKER_COMPOSE) down
	@echo "$(GREEN)Environment stopped$(NC)"

restart: ## Restart environment
	@echo "$(YELLOW)Restarting environment...$(NC)"
	$(DOCKER_COMPOSE) restart
	@echo "$(GREEN)Development restarted$(NC)"

logs: ## View logs
	$(DOCKER_COMPOSE) logs -f app

shell: ## Access container shell
	@echo "$(BLUE)Accessing container shell...$(NC)"
	$(DOCKER_COMPOSE) exec app sh

rebuild: down ## Rebuild and restart environment
	@echo "$(YELLOW)Rebuilding environment...$(NC)"
	$(DOCKER_COMPOSE) build --no-cache
	@$(MAKE) dev-up

##@ Composer & Dependencies

composer-install: ## Install composer dependencies
	@echo "$(GREEN)Installing composer dependencies...$(NC)"
	$(DOCKER_COMPOSE) exec app composer install

composer-update: ## Update composer dependencies
	@echo "$(GREEN)Updating composer dependencies...$(NC)"
	$(DOCKER_COMPOSE) exec app composer update

composer-require: ## Install a package (usage: make composer-require PACKAGE=vendor/package)
	@if [ -z "$(PACKAGE)" ]; then \
		echo "$(RED)Error: PACKAGE is required$(NC)"; \
		echo "Usage: make composer-require PACKAGE=vendor/package"; \
		exit 1; \
	fi
	@echo "$(GREEN)Installing $(PACKAGE)...$(NC)"
	$(DOCKER_COMPOSE) exec app composer require $(PACKAGE)

##@ Database

db-migrate: ## Run database migrations
	@echo "$(GREEN)Running database migrations...$(NC)"
	$(DOCKER_COMPOSE) exec app php bin/console doctrine:migrations:migrate --no-interaction

db-migrate-create: ## Create new migration
	@echo "$(GREEN)Creating new migration...$(NC)"
	$(DOCKER_COMPOSE) exec app php bin/console doctrine:migrations:diff

db-migrate-status: ## Check migration status
	$(DOCKER_COMPOSE) exec app php bin/console doctrine:migrations:status

db-fixtures: ## Load database fixtures
	@echo "$(GREEN)Loading database fixtures...$(NC)"
	$(DOCKER_COMPOSE) exec app php bin/console doctrine:fixtures:load --no-interaction

db-reset: ## Reset database (drop, create, migrate, fixtures)
	@echo "$(YELLOW)Resetting database...$(NC)"
	$(DOCKER_COMPOSE) exec app php bin/console doctrine:database:drop --force --if-exists
	$(DOCKER_COMPOSE) exec app php bin/console doctrine:database:create
	$(DOCKER_COMPOSE) exec app php bin/console doctrine:migrations:migrate --no-interaction
	@echo "$(GREEN)Database reset complete$(NC)"

##@ Cache

cache-clear: ## Clear Symfony cache
	@echo "$(GREEN)Clearing cache...$(NC)"
	$(DOCKER_COMPOSE) exec app php bin/console cache:clear

cache-warmup: ## Warm up Symfony cache
	@echo "$(GREEN)Warming up cache...$(NC)"
	$(DOCKER_COMPOSE) exec app php bin/console cache:warmup

##@ Code Quality

phpstan: ## Run PHPStan analysis
	@echo "$(GREEN)Running PHPStan...$(NC)"
	$(DOCKER_COMPOSE) exec app vendor/bin/phpstan analyse --memory-limit=1G

deptrac: ## Run Deptrac architecture analysis
	@echo "$(GREEN)Running Deptrac...$(NC)"
	$(DOCKER_COMPOSE) exec app vendor/bin/deptrac

cs-fix: ## Fix code style with PHP CS Fixer
	@echo "$(GREEN)Fixing code style...$(NC)"
	$(DOCKER_COMPOSE) exec app vendor/bin/php-cs-fixer fix

cs-check: ## Check code style
	@echo "$(GREEN)Checking code style...$(NC)"
	$(DOCKER_COMPOSE) exec app vendor/bin/php-cs-fixer fix --dry-run --diff

qa: phpstan deptrac cs-check ## Run all quality checks

##@ Testing

test: ## Run all tests
	@echo "$(GREEN)Running tests...$(NC)"
	$(DOCKER_COMPOSE) exec app vendor/bin/phpunit

test-coverage: ## Run tests with coverage
	@echo "$(GREEN)Running tests with coverage...$(NC)"
	$(DOCKER_COMPOSE) exec app php -d xdebug.mode=coverage vendor/bin/phpunit --coverage-html coverage-report
	@echo "$(BLUE)Coverage report: coverage-report/index.html$(NC)"

test-unit: ## Run unit tests only
	@echo "$(GREEN)Running unit tests...$(NC)"
	$(DOCKER_COMPOSE) exec app vendor/bin/phpunit tests/Unit

test-integration: ## Run integration tests only
	@echo "$(GREEN)Running integration tests...$(NC)"
	$(DOCKER_COMPOSE) exec app vendor/bin/phpunit tests/Integration

##@ Docker Management

ps: ## Show running containers
	$(DOCKER_COMPOSE) ps

clean: ## Remove all containers, volumes, and images
	@echo "$(RED)WARNING: This will remove all containers, volumes, and images!$(NC)"
	@echo -n "Are you sure? [y/N] " && read ans && [ $${ans:-N} = y ]
	$(DOCKER_COMPOSE) down -v --rmi all --remove-orphans
	@echo "$(GREEN)Cleanup complete$(NC)"

prune: ## Prune Docker system (free up space)
	@echo "$(YELLOW)Pruning Docker system...$(NC)"
	docker system prune -af --volumes
	@echo "$(GREEN)Docker system pruned$(NC)"

##@ Information

info: ## Show system information
	@echo "$(BLUE)System Information$(NC)"
	@echo "$(YELLOW)Detected OS:$(NC) $(DETECTED_OS)"
	@echo "$(YELLOW)USER_ID:$(NC)     $(USER_ID)"
	@echo "$(YELLOW)GROUP_ID:$(NC)    $(GROUP_ID)"
	@echo "$(YELLOW)Volume Flags:$(NC) $(VOLUME_FLAGS)"
	@echo ""
	@echo "$(BLUE)Docker Version:$(NC)"
	@docker --version
	@echo ""
	@echo "$(BLUE)Docker Compose Version:$(NC)"
	@docker compose version
	@echo ""
	@echo "$(BLUE)Running Containers:$(NC)"
	@$(DOCKER_COMPOSE) ps

check-env: ## Check if .env file exists
	@if [ ! -f .env ]; then \
		echo "$(RED)Error: .env file not found!$(NC)"; \
		echo "$(YELLOW)Run 'make init' to create it$(NC)"; \
		exit 1; \
	else \
		echo "$(GREEN).env file exists$(NC)"; \
	fi

##@ Convenience

fresh: clean init build up composer-install db-reset ## Fresh install (clean + setup + start)
	@echo ""
	@echo "$(GREEN)Fresh installation complete!$(NC)"
	@echo "$(BLUE)Application is ready at http://localhost:8080$(NC)"

restart: down up ## Quick restart (down + up)

rebuild: down build up ## Rebuild containers (down + build + up)

update: composer-update db-migrate cache-clear ## Update dependencies and database
	@echo "$(GREEN)Project updated!$(NC)"
