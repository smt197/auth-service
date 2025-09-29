# Laravel Auth Service with Docker

This is a Laravel-based authentication service using Docker with optimized configuration for production deployment.

## Architecture

The service uses:
- **Laravel Framework** with Octane for high performance
- **Docker** with serversideup/php image
- **s6-overlay** for process supervision
- **RabbitMQ** for event-driven communication
- **FrankenPHP** as the application server

## Services Management

The application uses s6-overlay to manage multiple Laravel processes:

### Core Services

1. **laravel-octane**
   - FrankenPHP server on port 8001
   - Auto workers and task workers
   - File watching for development
   - Max 1000 requests per worker

2. **laravel-queue-events**
   - Processes event queue jobs
   - 3 retry attempts with 3s backoff
   - Max 1000 jobs per worker
   - 60s timeout per job

3. **laravel-queue-rabbitmq**
   - Processes RabbitMQ queue jobs
   - Used for inter-service communication
   - Same retry and timeout configuration

4. **laravel-scheduler**
   - Runs Laravel scheduled tasks
   - Executes every 60 seconds
   - Uses `schedule:run` command

## Docker Configuration

### Dockerfile Features

- Based on `serversideup/php:8.3-fpm-nginx-alpine`
- Optimized PHP extensions for Laravel
- s6-overlay services for process management
- Proper file permissions for Laravel storage

### Environment Variables

Key environment variables for services:

```env
# s6-overlay services
AUTORUN_ENABLED=true
AUTORUN_LARAVEL_OCTANE=true
OCTANE_SERVER=frankenphp
OCTANE_HOST=0.0.0.0
OCTANE_PORT=8001

# Logging
LOG_CHANNEL=stderr

# RabbitMQ Configuration
RABBITMQ_HOST=rabbitmq.example.com
RABBITMQ_PORT=5672
RABBITMQ_USER=your_user
RABBITMQ_PASSWORD=your_password
RABBITMQ_VHOST=/
```

## Service Communication

The auth service publishes user events to RabbitMQ via the `PublishUserEventJob`:

- **Exchange**: `user_events` (topic)
- **Routing Keys**: `user.{event_type}`
- **Events**: user registration, login, logout, etc.

## Development

### Building the Image

```bash
docker build -f auth.dockerfile -t auth-service .
```

### Running with Docker Compose

```bash
docker-compose up -d
```

### Accessing Services

- **Application**: http://localhost (via NGINX)
- **Octane Server**: http://localhost:8001 (direct access)

## Production Considerations

1. **Process Supervision**: s6-overlay ensures all services restart on failure
2. **Performance**: FrankenPHP provides better performance than traditional PHP-FPM
3. **Scalability**: Queue workers can be scaled independently
4. **Monitoring**: All services log to stderr for container log aggregation
5. **Health Checks**: Built-in health monitoring via s6-overlay

## File Structure

```
├── s6-overlay/                    # s6-overlay service definitions
│   └── s6-rc.d/
│       ├── laravel-octane/        # Octane service
│       ├── laravel-queue-events/  # Event queue worker
│       ├── laravel-queue-rabbitmq/# RabbitMQ queue worker
│       ├── laravel-scheduler/     # Task scheduler
│       └── laravel-services/      # Service bundle
├── auth.dockerfile               # Docker build configuration
├── docker-compose.yaml          # Docker Compose configuration
└── README.md                    # This file
```

## Troubleshooting

### Common Issues

1. **Log Permissions**: The service uses `LOG_CHANNEL=stderr` to avoid file permission issues
2. **RabbitMQ Connection**: Ensure RabbitMQ server is accessible and credentials are correct
3. **Storage Permissions**: Docker handles Laravel storage permissions automatically

### Monitoring Services

Check s6-overlay service status inside the container:
```bash
docker exec -it <container> s6-svstat /run/service/*
```

View service logs:
```bash
docker logs <container>
```

---

## About Laravel

Laravel is a web application framework with expressive, elegant syntax. We believe development must be an enjoyable and creative experience to be truly fulfilling. Laravel takes the pain out of development by easing common tasks used in many web projects, such as:

- [Simple, fast routing engine](https://laravel.com/docs/routing).
- [Powerful dependency injection container](https://laravel.com/docs/container).
- Multiple back-ends for [session](https://laravel.com/docs/session) and [cache](https://laravel.com/docs/cache) storage.
- Expressive, intuitive [database ORM](https://laravel.com/docs/eloquent).
- Database agnostic [schema migrations](https://laravel.com/docs/migrations).
- [Robust background job processing](https://laravel.com/docs/queues).
- [Real-time event broadcasting](https://laravel.com/docs/broadcasting).

Laravel is accessible, powerful, and provides tools required for large, robust applications.

## Learning Laravel

Laravel has the most extensive and thorough [documentation](https://laravel.com/docs) and video tutorial library of all modern web application frameworks, making it a breeze to get started with the framework.

You may also try the [Laravel Bootcamp](https://bootcamp.laravel.com), where you will be guided through building a modern Laravel application from scratch.

If you don't feel like reading, [Laracasts](https://laracasts.com) can help. Laracasts contains thousands of video tutorials on a range of topics including Laravel, modern PHP, unit testing, and JavaScript. Boost your skills by digging into our comprehensive video library.

## Laravel Sponsors

We would like to extend our thanks to the following sponsors for funding Laravel development. If you are interested in becoming a sponsor, please visit the [Laravel Partners program](https://partners.laravel.com).

### Premium Partners

- **[Vehikl](https://vehikl.com)**
- **[Tighten Co.](https://tighten.co)**
- **[Kirschbaum Development Group](https://kirschbaumdevelopment.com)**
- **[64 Robots](https://64robots.com)**
- **[Curotec](https://www.curotec.com/services/technologies/laravel)**
- **[DevSquad](https://devsquad.com/hire-laravel-developers)**
- **[Redberry](https://redberry.international/laravel-development)**
- **[Active Logic](https://activelogic.com)**

## Contributing

Thank you for considering contributing to the Laravel framework! The contribution guide can be found in the [Laravel documentation](https://laravel.com/docs/contributions).

## Code of Conduct

In order to ensure that the Laravel community is welcoming to all, please review and abide by the [Code of Conduct](https://laravel.com/docs/contributions#code-of-conduct).

## Security Vulnerabilities

If you discover a security vulnerability within Laravel, please send an e-mail to Taylor Otwell via [taylor@laravel.com](mailto:taylor@laravel.com). All security vulnerabilities will be promptly addressed.

## License

The Laravel framework is open-sourced software licensed under the [MIT license](https://opensource.org/licenses/MIT).
