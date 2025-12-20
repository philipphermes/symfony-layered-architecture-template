# Symfony Layered Architecture Template

A modern Symfony template using a layered architecture pattern with FrankenPHP for high-performance PHP applications. Features a flexible Docker setup optimized for development and production across all platforms.

## Features

- 🚀 **FrankenPHP** - Modern PHP application server with built-in Caddy
- 🐳 **Multi-stage Docker** - Optimized dev/prod configurations
- 🔧 **Flexible PHP Extensions** - Configure via environment variables
- 🐛 **Xdebug Ready** - Pre-configured for development debugging
- 🗄️ **PostgreSQL** - Production-ready with health checks
- ⚡ **Cross-Platform** - Works seamlessly on Linux, Mac, and Windows
- 📦 **Live Reload** - Automatic file watching in development
- 🔒 **Production Optimized** - OPcache, JIT, preloading enabled
- 🎯 **Smart Makefile** - Auto-detects OS and applies optimal settings

## Requirements

- Docker Desktop (Mac/Windows) or Docker Engine (Linux)
- Docker Compose v2+
- Make (optional but recommended, for convenience commands)

## Quick Start

### First Time Setup (Automatic)

The Makefile automatically detects your operating system and configures everything:
```bash
# Initialize project (auto-detects OS and creates .env)
make init

# Build and start development environment
make fresh
```

That's it! The `make fresh` command will:
- Clean any existing containers
- Build the Docker images
- Start the services
- Install Composer dependencies
- Set up the database
- Configure optimal settings for your OS

### Manual Setup (Alternative)

If you prefer manual setup or don't have Make:
```bash
# Copy environment file
cp .env.example .env

# Add OS-specific settings to .env (see Platform-Specific Setup below)

# Build and start development
docker-compose build
docker-compose up -d

# Install dependencies
docker-compose exec app composer install
```

## Platform-Specific Details

The Makefile automatically handles platform differences:

### Linux
- **Auto-configured**: Uses your actual UID/GID for file permissions
- **Performance**: Native Docker performance (fastest)
- **Volume flags**: None needed

### macOS
- **Auto-configured**: Uses UID 1000/GID 1000
- **Performance**: Good with `:cached` flag (automatically applied)
- **Volume flags**: `:cached` for better performance

### Windows
- **Auto-configured**: Uses UID 1000/GID 1000
- **Performance**: Good with `:cached` flag (automatically applied)
- **Volume flags**: `:cached` for better performance

> **Note**: Run `make info` to see your detected OS and current configuration.

## Services & Ports

**Development:**
- Application: `http://localhost:8080`
- HTTPS: `https://localhost:8443`
- Caddy Admin API: `http://localhost:2019`
- PostgreSQL: `localhost:5432`
- Health Check: `http://localhost:8080/health`

**Production:**
- Application: `http://localhost:80` / `https://localhost:443`
- PostgreSQL: Internal network only

## Available Make Commands

Run `make help` or just `make` to see all available commands:

### Setup & Initialization
```bash
make init              # Initialize project (first time setup, auto-detects OS)
make fresh             # Fresh install (clean + setup + start)
make info              # Show system information and configuration
```

### Development
```bash
make dev-build         # Build development environment
make dev-up            # Start development environment
make dev-down          # Stop development environment
make dev-restart       # Restart development environment
make dev-rebuild       # Rebuild and restart (no cache)
make dev-logs          # View application logs
make dev-shell         # Access container shell
make restart           # Quick restart (alias for dev-down + dev-up)
make rebuild           # Rebuild containers (down + build + up)
```

### Composer & Dependencies
```bash
make composer-install  # Install composer dependencies
make composer-update   # Update composer dependencies
make composer-require PACKAGE=vendor/package  # Install a specific package
```

### Database
```bash
make db-migrate        # Run database migrations
make db-migrate-create # Create new migration
make db-migrate-status # Check migration status
make db-fixtures       # Load database fixtures
make db-reset          # Reset database (drop, create, migrate)
```

### Cache Management
```bash
make cache-clear       # Clear Symfony cache
make cache-warmup      # Warm up Symfony cache
```

### Code Quality
```bash
make phpstan           # Run PHPStan static analysis
make deptrac           # Run Deptrac architecture analysis
make cs-fix            # Fix code style with PHP CS Fixer
make cs-check          # Check code style (dry-run)
make qa                # Run all quality checks
```

### Testing
```bash
make test              # Run all tests
make test-coverage     # Run tests with coverage report
make test-unit         # Run unit tests only
make test-integration  # Run integration tests only
```

### Production
```bash
make prod-build        # Build production containers
make prod-up           # Start production environment
make prod-down         # Stop production environment
make prod-logs         # View production logs
make prod-shell        # Access production container shell
```

### Docker Management
```bash
make ps                # Show running containers
make stats             # Show container resource usage
make clean             # Remove all containers, volumes, and images
make prune             # Prune Docker system (free up space)
```

### Convenience Commands
```bash
make update            # Update dependencies and database
```

## Development

### Using Make Commands (Recommended)
```bash
# Database migrations
make db-migrate-create  # Create new migration
make db-migrate         # Run migrations

# Code quality
make phpstan            # Static analysis
make deptrac            # Architecture validation
make cs-fix             # Fix code style

# Testing
make test               # Run tests
make test-coverage      # Run with coverage
```

### Using Docker Compose Directly
```bash
# Database migrations
docker-compose exec app php bin/console doctrine:migrations:diff
docker-compose exec app php bin/console doctrine:migrations:migrate

# Code quality
docker-compose exec app vendor/bin/deptrac
docker-compose exec app vendor/bin/phpstan analyse --memory-limit=1G
docker-compose exec app vendor/bin/php-cs-fixer fix

# Testing
docker-compose exec app vendor/bin/phpunit
docker-compose exec app php -d xdebug.mode=coverage vendor/bin/phpunit --coverage-html coverage-report
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

## Production Deployment

### Build Production Image
```bash
# Using Make
make prod-build

# Or with Docker Compose
docker-compose -f docker-compose.prod.yml build

# Or for container registry
docker build \
  --target prod \
  --build-arg PHP_VERSION=8.4 \
  --build-arg PHP_EXTENSIONS="pdo_pgsql intl zip opcache" \
  -t your-registry/symfony-app:latest \
  -f docker/frankenphp/Dockerfile \
  .

# Push to registry
docker push your-registry/symfony-app:latest
```

### Deploy Production
```bash
# Using Make
make prod-up

# Or with Docker Compose
docker-compose -f docker-compose.prod.yml up -d

# Or pull from registry and run
docker pull your-registry/symfony-app:latest
docker run -d \
  -p 80:80 \
  -p 443:443 \
  --env-file .env.prod \
  your-registry/symfony-app:latest
```

### Production Checklist

- [ ] Set strong `POSTGRES_PASSWORD` in `.env`
- [ ] Configure `APP_SECRET` in `.env`
- [ ] Set `APP_ENV=prod` and `APP_DEBUG=0`
- [ ] Configure proper DATABASE_URL
- [ ] Set up SSL certificates (FrankenPHP auto-generates with proper domain)
- [ ] Configure backup strategy for database
- [ ] Set up monitoring and logging
- [ ] Review and adjust resource limits in docker-compose.prod.yml

## Project Structure
```
├── config/              # Symfony configuration
├── docker/
│   └── frankenphp/
│       ├── Dockerfile           # Multi-stage build
│       ├── Caddyfile.dev       # Development Caddy config
│       ├── Caddyfile.prod      # Production Caddy config
│       ├── docker-entrypoint.sh
│       ├── xdebug.ini
│       ├── opcache.dev.ini
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
├── Makefile                     # Convenience commands (auto-detects OS)
└── .gitattributes              # Cross-platform line endings
```

## Environment Variables

The `.env` file is automatically created by `make init` with OS-specific settings.

Key environment variables:
```bash
# App
APP_ENV=dev
APP_SECRET=your-secret-here

# Database
POSTGRES_VERSION=16
POSTGRES_DB=app
POSTGRES_USER=app
POSTGRES_PASSWORD=!ChangeMe!
POSTGRES_PORT=5432

# Docker (auto-configured by make init)
USER_ID=1000              # Auto-set based on OS
GROUP_ID=1000             # Auto-set based on OS
VOLUME_FLAGS=cached       # Auto-set based on OS (cached for Mac/Windows, empty for Linux)
```

## Customizing PHP Extensions

Edit `docker-compose.yml` build args:
```yaml
args:
  PHP_VERSION: "8.4"
  PHP_EXTENSIONS: "pdo_pgsql intl zip opcache xml gd"
  PECL_EXTENSIONS: "redis"
  APK_PACKAGES: "postgresql-dev icu-dev libzip-dev git unzip"
```

Available extensions via `install-php-extensions`:
- `pdo_pgsql` - PostgreSQL
- `pdo_mysql` - MySQL
- `intl` - Internationalization
- `opcache` - OPcache
- `redis` - Redis
- `apcu` - APCu
- `gd` - Image processing
- `imagick` - ImageMagick
- And many more...

## Performance Tips

### Development
- Use named volumes for `vendor/` and `var/` directories (already configured)
- Enable file watching with `--watch` flag (already configured)
- Use `:cached` flag for Mac/Windows volume mounts (auto-configured by Makefile)
- Run `make info` to verify optimal settings for your platform

### Production
- OPcache with preloading enabled
- JIT compilation enabled
- Static assets cached with long expiry
- Autoloader optimized and authoritative
- No Xdebug or development tools

## Troubleshooting

### Check Your Configuration
```bash
# View current OS and configuration
make info

# Output example:
# System Information
# Detected OS: macOS
# USER_ID:     1000
# GROUP_ID:    1000
# Volume Flags: cached
```

### Container exits immediately
```bash
# Check logs
make dev-logs
# or
docker-compose logs app

# Rebuild without cache
make dev-rebuild
# or
docker-compose build --no-cache
docker-compose up
```

### Permission issues (Linux)
```bash
# Reinitialize with correct permissions
make init
make rebuild
```

The Makefile automatically uses your actual UID/GID on Linux, so this should rarely be an issue.

### Slow performance (Mac/Windows)
```bash
# Verify you're using named volumes and cached flag
make info

# Ensure docker-compose.yml has:
volumes:
  - ./:/app:${VOLUME_FLAGS:-cached}
  - symfony_vendor:/app/vendor
  - symfony_var:/app/var
```

### Dependencies not installed
```bash
# Install manually
make composer-install
# or
docker-compose exec app composer install

# Or start fresh
make fresh
```

### Make not available

If `make` is not installed on your system:

**Linux:**
```bash
sudo apt-get install make  # Debian/Ubuntu
sudo yum install make      # CentOS/RHEL
```

**macOS:**
```bash
xcode-select --install
```

**Windows:**
```powershell
# Install via Chocolatey
choco install make

# Or use WSL (Windows Subsystem for Linux)
```

Alternatively, use Docker Compose commands directly (see examples above).

## Common Workflows

### Starting a fresh development environment
```bash
make fresh
# This runs: clean → init → dev-build → dev-up → composer-install → db-reset
```

### Daily development
```bash
# Start work
make dev-up

# View logs
make dev-logs

# Run tests
make test

# End of day
make dev-down
```

### After pulling changes
```bash
# Update dependencies and database
make update
# This runs: composer-update → db-migrate → cache-clear
```

### Running quality checks before commit
```bash
make qa
# This runs: phpstan → deptrac → cs-check
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Run quality checks: `make qa`
4. Run tests: `make test`
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

- 📖 [Symfony Documentation](https://symfony.com/doc)
- 🚀 [FrankenPHP Documentation](https://frankenphp.dev/)
- 🐳 [Docker Documentation](https://docs.docker.com/)
- 💬 [GitHub Issues](https://github.com/philipphermes/symfony-layered-architecture-template/issues)

---

**Pro Tip**: Run `make help` anytime to see all available commands with descriptions!
