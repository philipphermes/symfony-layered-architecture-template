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

## Requirements

- Docker Desktop (Mac/Windows) or Docker Engine (Linux)
- Docker Compose v2+
- Make (optional, for convenience commands)

## Quick Start

### Using Make (Recommended)
```bash
# Copy environment file
cp .env.example .env

# Build and start development environment
make dev-build
make dev-up

# View logs
make dev-logs

# Access container shell
make dev-shell

# Install dependencies
make composer-install

# Stop environment
make dev-down
```

### Using Docker Compose Directly
```bash
# Copy environment file
cp .env.example .env

# Build and start development
docker-compose build
docker-compose up -d

# View logs
docker-compose logs -f app

# Access container
docker-compose exec app sh

# Stop environment
docker-compose down
```

## Platform-Specific Setup

### Linux
```bash
# Set your user ID for proper file permissions
echo "USER_ID=$(id -u)" >> .env
echo "GROUP_ID=$(id -g)" >> .env
echo "VOLUME_FLAGS=" >> .env

make dev-build && make dev-up
```

### Mac
```bash
# Use cached volumes for better performance
echo "USER_ID=1000" >> .env
echo "GROUP_ID=1000" >> .env
echo "VOLUME_FLAGS=cached" >> .env

make dev-build && make dev-up
```

### Windows
```bash
# Use default settings
echo "USER_ID=1000" >> .env
echo "GROUP_ID=1000" >> .env
echo "VOLUME_FLAGS=cached" >> .env

# Using Make for Windows or docker-compose directly
make dev-build && make dev-up
# OR
docker-compose build && docker-compose up -d
```

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

## Development

### Database Migrations
```bash
# Create migration
docker-compose exec app php bin/console doctrine:migrations:diff

# Run migrations
docker-compose exec app php bin/console doctrine:migrations:migrate

# Execute specific migration
docker-compose exec app php bin/console migrations:execute --up "DoctrineMigrations\\{version}"
docker-compose exec app php bin/console migrations:execute --down "DoctrineMigrations\\{version}"
```

### Code Quality
```bash
# Deptrac (architecture validation)
docker-compose exec app vendor/bin/deptrac

# PHPStan (static analysis)
docker-compose exec app vendor/bin/phpstan analyse --memory-limit=1G

# PHP CS Fixer (code style)
docker-compose exec app vendor/bin/php-cs-fixer fix
```

### Testing
```bash
# Run all tests
docker-compose exec app vendor/bin/phpunit

# With coverage report
docker-compose exec app php -d xdebug.mode=coverage vendor/bin/phpunit --coverage-html coverage-report

# Run specific test
docker-compose exec app vendor/bin/phpunit tests/Unit/YourTest.php
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

### Cache Management
```bash
# Clear cache
docker-compose exec app php bin/console cache:clear

# Warm up cache
docker-compose exec app php bin/console cache:warmup

# Clear specific cache pool
docker-compose exec app php bin/console cache:pool:clear cache.app
```

## Production Deployment

### Build Production Image
```bash
# Build production image
docker-compose -f docker-compose.prod.yml build

# Or with specific tag for registry
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
# Using docker-compose
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
├── public/ # Web root
├── src/
│   ├── Backend/
│   │   └── {Module}
│   │       ├── Business/ # Facades and Business logic
│   │       ├── Communication/ # Controllers and commands
│   │       ├── Persistence/ # Entities, repositories & entity managers
│   │       └── Presentation/ # Templates and js
│   ├── Frontend/
│   │   └── {Module}
│   │       ├── Controller/ # Controllers
│   │       └── Theme/ # Templates and js
│   ├── Services/
│   │   └── {Module}
│   ├── Shared/
│   │   └── {Module}
│   │       ├── Transfers/
│   │       └── ...
│   └── Generated/ # Migrations, Generated Transfers, ...
├── tests/ # Test suite
├── docker-compose.yml # Development compose file
├── docker-compose.prod.yml # Production compose file
├── Makefile # Convenience commands
└── .gitattributes # Cross-platform line endings
```

## Environment Variables

Key environment variables (add to `.env`):
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

# Docker (for development)
USER_ID=1000
GROUP_ID=1000
VOLUME_FLAGS=cached  # Use 'cached' for Mac/Windows, '' for Linux
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
- Use named volumes for `vendor/` and `var/` directories
- Enable file watching with `--watch` flag (already configured)
- Use `:cached` flag for Mac/Windows volume mounts

### Production
- OPcache with preloading enabled
- JIT compilation enabled
- Static assets cached with long expiry
- Autoloader optimized and authoritative
- No Xdebug or development tools

## Troubleshooting

### Container exits immediately
```bash
# Check logs
docker-compose logs app

# Rebuild without cache
docker-compose build --no-cache
docker-compose up
```

### Permission issues (Linux)
```bash
# Set correct USER_ID and GROUP_ID in .env
echo "USER_ID=$(id -u)" >> .env
echo "GROUP_ID=$(id -g)" >> .env

# Rebuild
docker-compose down -v
docker-compose build
docker-compose up -d
```

### Slow performance (Mac/Windows)
```bash
# Ensure you're using named volumes for vendor/var
# Check docker-compose.yml has:
volumes:
  - symfony_vendor:/app/vendor
  - symfony_var:/app/var
```

### Dependencies not installed
```bash
# Install manually
docker-compose exec app composer install

# Or rebuild with clean volumes
docker-compose down -v
docker-compose up --build
```

## Available Make Commands

Run `make help` to see all available commands:
```bash
make help              # Show all commands
make dev-build         # Build development environment
make dev-up            # Start development environment
make dev-down          # Stop development environment
make dev-logs          # View application logs
make dev-shell         # Access container shell
make composer-install  # Install composer dependencies
make prod-build        # Build production environment
make prod-up           # Start production environment
make prod-down         # Stop production environment
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

- 📖 [Symfony Documentation](https://symfony.com/doc)
- 🚀 [FrankenPHP Documentation](https://frankenphp.dev/)
- 🐳 [Docker Documentation](https://docs.docker.com/)
- 💬 [GitHub Issues](https://github.com/philipphermes/symfony-layered-architecture-template/issues)
