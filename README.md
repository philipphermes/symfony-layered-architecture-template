# Symfony Layered Architecture Template (WIP)

This template provides a starting point for Symfony projects using a layered architecture.

### TODOS:
- [ ] Add Docker support (only dev yet)

## Usage

### Start containers and server:
```bash
docker/dev
```

### Start containers:
```bash
docker compose up -d
```

### Enter the PHP container:
```bash
docker-compose exec app bash
```

### Serve your Symfony app:
```bash
symfony server:start --no-tls --allow-http --listen-ip=0.0.0.0 --port=8000
```

## Transfers

### Generate Transfers
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

## Code Quality

### Deptrac
```bash
vendor/bin/deptrac
```

### Phpstan
```bash
vendor/bin/phpstan analyse --memory-limit=1G
```

## Test

### Phpunit
```bash
vendor/bin/phpunit

# With coverage
XDEBUG_MODE=coverage vendor/bin/phpunit --coverage-html coverage-report
```
