# Symfony Layered Architecture Template

A modern Symfony template using a layered architecture pattern with FrankenPHP for high-performance PHP applications. Features a flexible Docker setup optimized for development and production across all platforms.


[![CI](https://github.com/philipphermes/symfony-layered-architecture-template/actions/workflows/ci.yaml/badge.svg)](https://github.com/philipphermes/symfony-layered-architecture-template/actions/workflows/ci.yaml)
[![PHP](https://img.shields.io/badge/php-%3E%3D%208.4-8892BF.svg)]((https://img.shields.io/badge/php-%3E%3D%208.4-8892BF.svg))
[![Symfony](https://img.shields.io/badge/symfony-8-8892BF.svg)]((https://img.shields.io/badge/symfony-8-8892BF.svg))
[![codecov](https://codecov.io/gh/philipphermes/symfony-layered-architecture-template/graph/badge.svg?token=BTQ0TLXHI0)](https://codecov.io/gh/philipphermes/symfony-layered-architecture-template)

## Features

- 🚀 **FrankenPHP** - Modern PHP application server with built-in Caddy
- 🐳 **Multi-stage Docker** - Optimized dev/prod configurations
- 🔧 **Flexible PHP Extensions** - Configure via environment variables
- 🐛 **Xdebug Ready** - Pre-configured for development debugging (was not able to get it to work yet)
- 🗄️ **PostgreSQL** - Production-ready with health checks
- ⚡ **Cross-Platform** - Works seamlessly on Linux, Mac, and Windows
- 📦 **Live Reload** - Automatic file watching in development
- 🔒 **Production Optimized** - OPcache, JIT, preloading enabled

## Requirements

- Docker Desktop (Mac/Windows) or Docker Engine (Linux)
- Docker Compose v2+

## Quick Start

### Setup

```bash
# Create .env
cp .env.dist .env

# Initialize project
docker/console boot docker-compose.yml #(or docker-compose.test.yml or docker-compose.prod.yml)

# Start project and install dependencies
docker/console install

# Access shell
docker/console cli
```

## Services & Ports

**Development:**
- Application: http://localhost:8080
- HTTPS: https://localhost:8443
- Caddy Admin API: http://localhost:2019
- PostgreSQL: `localhost:5432`
- Health Check: http://localhost:8080/health

**Production:**
- Application: `http://localhost:80` / `https://localhost:443`
- PostgreSQL: Internal network only

## Available Docker Commands

```bash
docker/console boot {file} # Initialize project
docker/console up          # Start project
docker/console start       # Start project
docker/console stop        # Stop project
docker/console down        # Removes containers and volumes
docker/console cli         # Access shell
docker/console install     # Start project, install dependencies and run migrations
docker/console reset       # Reset project (down & install)
```

### Debugging with Xdebug

Xdebug is pre-configured in development mode:

1. **PHPStorm/IntelliJ:**
    - Go to Settings → PHP → Servers
    - Add server: Name: `app`, Host: `localhost`, Port: `8080`
    - Enable path mappings: `/path/to/your/project` → `/app`
    - Start listening for debug connections

2. **VS Code:**
    - Install PHP Debug extension
    - Add to `.vscode/launch.json`:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Listen for Xdebug",
      "type": "php",
      "request": "launch",
      "port": 9003,
      "pathMappings": {
        "/app": "${workspaceFolder}"
      }
    }
  ]
}
```

## Project Structure
```
├── config/              # Symfony configuration
├── docker/
│   └── frankenphp/
│       ├── Dockerfile           # Multi-stage build
│       ├── Caddyfile       # Development Caddy config
│       ├── Caddyfile.prod      # Production Caddy config
│       ├── xdebug.ini
│       ├── opcache.ini
│       └── opcache.prod.ini
├── public/              # Web root
├── src/
│   ├── Backend/
│   │   └── {Module}
│   │       ├── Business/        # Facades and Business logic
│   │       ├── Communication/   # Controllers and commands
│   │       ├── Persistence/     # Entities, repositories & entity managers
│   │       └── Presentation/    # Templates and js
│   ├── Frontend/
│   │   └── {Module}
│   │       ├── Controller/      # Controllers
│   │       └── Theme/           # Templates and js
│   ├── Services/
│   │   └── {Module}
│   ├── Shared/
│   │   └── {Module}
│   │       ├── Transfers/
│   │       └── ...
│   └── Generated/       # Migrations, Generated Transfers, ...
├── tests/               # Test suite
├── docker-compose.yml           # Development compose file
├── docker-compose.prod.yml      # Production compose file
├── docker-compose.test.yml      # Test compose file
└── .gitattributes              # Cross-platform line endings
```

## Testing

```
vendor/bin/phpunit

# With coverage
XDEBUG_MODE=coverage vendor/bin/phpunit --coverage-html coverage
```

## Sniffers

```bash
#Deptrac
vendor/bin/deptrac

#Phpstan
vendor/bin/phpstan analyse --memory-limit=1G
```

## Generate Transfers

```bash
symfony console transfer:generate
```

## Migrations:
Create migration files:
```bash
php bin/console doctrine:migrations:diff
```

Run migration files:
```bash
php bin/console doctrine:migrations:migrate
```

Run migration for testing purposes:
```bash
migrations:execute --up "DoctrineMigrations\\{version}"
```

Revert the migration:
```bash
migrations:execute --down "DoctrineMigrations\\{version}"
```
