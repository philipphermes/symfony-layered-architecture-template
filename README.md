# Symfony Layered Architecture Template (WIP)

This template provides a starting point for Symfony projects using a layered architecture.

### TODOS:
- [ ] Add Docker support
- [ ] Add more documentation
- [ ] Add basic user authentication as starter point/example

## Transfers

### Generate Transfers
```bash
symfony console transfer:generate
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
