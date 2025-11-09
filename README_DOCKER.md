# Docker / docker-compose for lottery_single

This file explains how to build and run the project with Docker and docker-compose.

Prerequisites:
- Docker and docker-compose installed on the host
- Ports 8081 (app), 3307 (mysql) and 6379 (redis) available or change mappings in `docker-compose.yml`

Files created:
- `Dockerfile` - multi-stage image to build the Go binary and create a minimal runtime image
- `.dockerignore` - reduce build context size
- `docker-compose.yml` - runs `app`, `mysql`, and `redis`
- `configs/docker-config.yml` - configuration used when running in docker-compose; it points DB/Redis to service names (`mysql`, `redis`)

Quick start (from project root):

1. Build and run with docker-compose

```powershell
# build and start services
docker-compose up --build -d

# view logs
docker-compose logs -f app

# stop and remove
docker-compose down
```

Notes:
- `docker-compose.yml` mounts `./configs/docker-config.yml` into the app container at `/app/configs/config.yml`, so the application will connect to the MySQL and Redis services by name.
- If you want to use an external DB/Redis, either edit `configs/config.yml` or override `./configs/docker-config.yml` before `docker-compose up`.
- The MySQL root password and DB name are set in `docker-compose.yml`. Adjust them as necessary.
