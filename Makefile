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

# Docker Compose command (v2 syntax)
DOCKER_COMPOSE := docker compose
DOCKER_COMPOSE_DEV := $(DOCKER_COMPOSE) -f docker-compose.yaml
DOCKER_COMPOSE_TEST := $(DOCKER_COMPOSE) -f docker-compose.test.yaml
DOCKER_COMPOSE_PROD := $(DOCKER_COMPOSE) -f docker-compose.prod.yaml

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

##@ Development

dev-build: ## Build development containers
	@echo "$(GREEN)Building development containers for $(DETECTED_OS)...$(NC)"
	@echo "$(YELLOW)USER_ID=$(USER_ID) GROUP_ID=$(GROUP_ID)$(NC)"
	$(DOCKER_COMPOSE_DEV) build --build-arg USER_ID=$(USER_ID) --build-arg GROUP_ID=$(GROUP_ID)
	@echo "$(GREEN)Build complete!$(NC)"

dev-up: ## Start development environment
	@echo "$(GREEN)Starting development environment on $(DETECTED_OS)...$(NC)"
	$(DOCKER_COMPOSE_DEV) up -d
	@echo ""
	@echo "$(GREEN)Development environment is running!$(NC)"
	@echo "$(BLUE)Application: http://localhost:8080$(NC)"
	@echo "$(BLUE)Database:    localhost:5432$(NC)"
	@echo "$(BLUE)Health:      http://localhost:8080/health$(NC)"
	@echo ""
	@echo "Run '$(YELLOW)make dev-logs$(NC)' to view logs"

dev-down: ## Stop development environment
	@echo "$(YELLOW)Stopping development environment...$(NC)"
	$(DOCKER_COMPOSE_DEV) down
	@echo "$(GREEN)Development environment stopped$(NC)"

dev-restart: ## Restart development environment
	@echo "$(YELLOW)Restarting development environment...$(NC)"
	$(DOCKER_COMPOSE_DEV) restart
	@echo "$(GREEN)Development environment restarted$(NC)"

dev-logs: ## View development logs
	$(DOCKER_COMPOSE_DEV) logs -f app

dev-shell: ## Access container shell
	@echo "$(BLUE)Accessing container shell...$(NC)"
	$(DOCKER_COMPOSE_DEV) exec app sh

dev-rebuild: dev-down ## Rebuild and restart development environment
	@echo "$(YELLOW)Rebuilding development environment...$(NC)"
	$(DOCKER_COMPOSE_DEV) build --no-cache
	@$(MAKE) dev-up

##@ Testing

test-build: ## Build testing containers
	@echo "$(GREEN)Building testing containers for $(DETECTED_OS)...$(NC)"
	@echo "$(YELLOW)USER_ID=$(USER_ID) GROUP_ID=$(GROUP_ID)$(NC)"
	$(DOCKER_COMPOSE_TEST) build --build-arg USER_ID=$(USER_ID) --build-arg GROUP_ID=$(GROUP_ID)
	@echo "$(GREEN)Build complete!$(NC)"

test-up: ## Start testing environment
	@echo "$(GREEN)Starting testing environment on $(DETECTED_OS)...$(NC)"
	$(DOCKER_COMPOSE_TEST) up -d
	@echo ""
	@echo "$(GREEN)Testing environment is running!$(NC)"
	@echo "$(BLUE)Application: http://localhost:8080$(NC)"
	@echo "$(BLUE)Database:    localhost:5432$(NC)"
	@echo "$(BLUE)Health:      http://localhost:8080/health$(NC)"
	@echo ""
	@echo "Run '$(YELLOW)make test-logs$(NC)' to view logs"

test-down: ## Stop testing environment
	@echo "$(YELLOW)Stopping testing environment...$(NC)"
	$(DOCKER_COMPOSE_TEST) down
	@echo "$(GREEN)Testing environment stopped$(NC)"

test-restart: ## Restart testing environment
	@echo "$(YELLOW)Restarting testing environment...$(NC)"
	$(DOCKER_COMPOSE_TEST) restart
	@echo "$(GREEN)Testing environment restarted$(NC)"

test-logs: ## View testing logs
	$(DOCKER_COMPOSE_TEST) logs -f app

test-shell: ## Access container shell
	@echo "$(BLUE)Accessing container shell...$(NC)"
	$(DOCKER_COMPOSE_TEST) exec app sh

test-rebuild: test-down ## Rebuild and restart testing environment
	@echo "$(YELLOW)Rebuilding testing environment...$(NC)"
	$(DOCKER_COMPOSE_TEST) build --no-cache
	@$(MAKE) test-up

##@ Composer & Dependencies

composer-install: ## Install composer dependencies
	@echo "$(GREEN)Installing composer dependencies...$(NC)"
	$(DOCKER_COMPOSE_DEV) exec app composer install

composer-update: ## Update composer dependencies
	@echo "$(GREEN)Updating composer dependencies...$(NC)"
	$(DOCKER_COMPOSE_DEV) exec app composer update

composer-require: ## Install a package (usage: make composer-require PACKAGE=vendor/package)
	@if [ -z "$(PACKAGE)" ]; then \
		echo "$(RED)Error: PACKAGE is required$(NC)"; \
		echo "Usage: make composer-require PACKAGE=vendor/package"; \
		exit 1; \
	fi
	@echo "$(GREEN)Installing $(PACKAGE)...$(NC)"
	$(DOCKER_COMPOSE_DEV) exec app composer require $(PACKAGE)

##@ Database

db-migrate: ## Run database migrations
	@echo "$(GREEN)Running database migrations...$(NC)"
	$(DOCKER_COMPOSE_DEV) exec app php bin/console doctrine:migrations:migrate --no-interaction

db-migrate-create: ## Create new migration
	@echo "$(GREEN)Creating new migration...$(NC)"
	$(DOCKER_COMPOSE_DEV) exec app php bin/console doctrine:migrations:diff

db-migrate-status: ## Check migration status
	$(DOCKER_COMPOSE_DEV) exec app php bin/console doctrine:migrations:status

db-fixtures: ## Load database fixtures
	@echo "$(GREEN)Loading database fixtures...$(NC)"
	$(DOCKER_COMPOSE_DEV) exec app php bin/console doctrine:fixtures:load --no-interaction

db-reset: ## Reset database (drop, create, migrate, fixtures)
	@echo "$(YELLOW)Resetting database...$(NC)"
	$(DOCKER_COMPOSE_DEV) exec app php bin/console doctrine:database:drop --force --if-exists
	$(DOCKER_COMPOSE_DEV) exec app php bin/console doctrine:database:create
	$(DOCKER_COMPOSE_DEV) exec app php bin/console doctrine:migrations:migrate --no-interaction
	@echo "$(GREEN)Database reset complete$(NC)"

##@ Cache

cache-clear: ## Clear Symfony cache
	@echo "$(GREEN)Clearing cache...$(NC)"
	$(DOCKER_COMPOSE_DEV) exec app php bin/console cache:clear

cache-warmup: ## Warm up Symfony cache
	@echo "$(GREEN)Warming up cache...$(NC)"
	$(DOCKER_COMPOSE_DEV) exec app php bin/console cache:warmup

##@ Code Quality

phpstan: ## Run PHPStan analysis
	@echo "$(GREEN)Running PHPStan...$(NC)"
	$(DOCKER_COMPOSE_TEST) exec app vendor/bin/phpstan analyse --memory-limit=1G

deptrac: ## Run Deptrac architecture analysis
	@echo "$(GREEN)Running Deptrac...$(NC)"
	$(DOCKER_COMPOSE_TEST) exec app vendor/bin/deptrac

cs-fix: ## Fix code style with PHP CS Fixer
	@echo "$(GREEN)Fixing code style...$(NC)"
	$(DOCKER_COMPOSE_TEST) exec app vendor/bin/php-cs-fixer fix

cs-check: ## Check code style
	@echo "$(GREEN)Checking code style...$(NC)"
	$(DOCKER_COMPOSE_TEST) exec app vendor/bin/php-cs-fixer fix --dry-run --diff

qa: phpstan deptrac cs-check ## Run all quality checks

##@ Testing

test: ## Run all tests
	@echo "$(GREEN)Running tests...$(NC)"
	$(DOCKER_COMPOSE_TEST) exec app vendor/bin/phpunit

test-coverage: ## Run tests with coverage
	@echo "$(GREEN)Running tests with coverage...$(NC)"
	$(DOCKER_COMPOSE_DEV) exec app php -d xdebug.mode=coverage vendor/bin/phpunit --coverage-html coverage-report
	@echo "$(BLUE)Coverage report: coverage-report/index.html$(NC)"

test-unit: ## Run unit tests only
	@echo "$(GREEN)Running unit tests...$(NC)"
	$(DOCKER_COMPOSE_DEV) exec app vendor/bin/phpunit tests/Unit

test-integration: ## Run integration tests only
	@echo "$(GREEN)Running integration tests...$(NC)"
	$(DOCKER_COMPOSE_DEV) exec app vendor/bin/phpunit tests/Integration

##@ Production

prod-build: ## Build production containers
	@echo "$(GREEN)Building production containers...$(NC)"
	$(DOCKER_COMPOSE_PROD) build
	@echo "$(GREEN)Production build complete!$(NC)"

prod-up: ## Start production environment
	@echo "$(GREEN)Starting production environment...$(NC)"
	$(DOCKER_COMPOSE_PROD) up -d
	@echo ""
	@echo "$(GREEN)Production environment is running!$(NC)"
	@echo "$(BLUE)Application: http://localhost$(NC)"
	@echo ""

prod-down: ## Stop production environment
	@echo "$(YELLOW)Stopping production environment...$(NC)"
	$(DOCKER_COMPOSE_PROD) down
	@echo "$(GREEN)Production environment stopped$(NC)"

prod-logs: ## View production logs
	$(DOCKER_COMPOSE_PROD) logs -f app

prod-shell: ## Access production container shell
	@echo "$(BLUE)Accessing production container shell...$(NC)"
	$(DOCKER_COMPOSE_PROD) exec app sh

##@ Docker Management

ps: ## Show running containers
	$(DOCKER_COMPOSE_DEV) ps

stats: ## Show container resource usage
	docker stats $(PROJECT_NAME)_app_dev $(PROJECT_NAME)_db_dev

clean: ## Remove all containers, volumes, and images
	@echo "$(RED)WARNING: This will remove all containers, volumes, and images!$(NC)"
	@echo -n "Are you sure? [y/N] " && read ans && [ $${ans:-N} = y ]
	$(DOCKER_COMPOSE_DEV) down -v --rmi all --remove-orphans
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
	@$(DOCKER_COMPOSE_DEV) ps

check-env: ## Check if .env file exists
	@if [ ! -f .env ]; then \
		echo "$(RED)Error: .env file not found!$(NC)"; \
		echo "$(YELLOW)Run 'make init' to create it$(NC)"; \
		exit 1; \
	else \
		echo "$(GREEN).env file exists$(NC)"; \
	fi

##@ Convenience

fresh: clean init dev-build dev-up composer-install db-reset ## Fresh install (clean + setup + start)
	@echo ""
	@echo "$(GREEN)Fresh installation complete!$(NC)"
	@echo "$(BLUE)Application is ready at http://localhost:8080$(NC)"

restart: dev-down dev-up ## Quick restart (down + up)

rebuild: dev-down dev-build dev-up ## Rebuild containers (down + build + up)

update: composer-update db-migrate cache-clear ## Update dependencies and database
	@echo "$(GREEN)Project updated!$(NC)"
