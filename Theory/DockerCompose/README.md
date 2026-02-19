# Docker Compose 

**Docker Compose** is a YAML-based abstraction layer over multiple `docker run` commands. It:

1. **Translates directly**: Every Compose option has a corresponding `docker run` flag
2. **Simplifies complex setups**: Instead of remembering multiple commands, you define everything in one file
3. **Manages relationships**: Handles dependencies between containers automatically
4. **Provides consistency**: Ensures the same configuration is used every time

### Example: Running Nginx with Docker Run
```bash
# Single docker run command with various options
docker run \
  --name my-nginx \
  -p 8080:80 \
  -v ./html:/usr/share/nginx/html \
  -e NGINX_HOST=localhost \
  --restart unless-stopped \
  -d \
  nginx:alpine
```

### Same Setup with Docker Compose:
```yaml
# docker-compose.yml - This does the SAME thing as above command
version: '3.8'
services:
  nginx:
    image: nginx:alpine          # Image name (same as in docker run)
    container_name: my-nginx     # --name my-nginx
    ports:
      - "8080:80"               # -p 8080:80
    volumes:
      - ./html:/usr/share/nginx/html  # -v ./html:/usr/share/nginx/html
    environment:
      - NGINX_HOST=localhost    # -e NGINX_HOST=localhost
    restart: unless-stopped     # --restart unless-stopped
    # Note: -d flag in docker run = detached mode
    # In docker-compose, use: docker-compose up -d
```

## Docker Run Flags to Compose

### 1. **Port Mapping**
```bash
# Docker Run
docker run -p 8080:80 -p 3000:3000 nginx
```
```yaml
# Docker Compose
ports:
  - "8080:80"
  - "3000:3000"
```

### 2. **Volume Mounting**
```bash
# Docker Run
docker run -v ./data:/app/data -v myvolume:/app/config nginx
```
```yaml
# Docker Compose
volumes:
  - ./data:/app/data           # Bind mount (host path)
  - myvolume:/app/config       # Named volume
  
# Also define named volumes at the bottom:
volumes:
  myvolume:                    # This creates the named volume
```

### 3. **Environment Variables**
```bash
# Docker Run
docker run -e DB_HOST=localhost -e DB_PORT=5432 app
```
```yaml
# Docker Compose
environment:
  - DB_HOST=localhost
  - DB_PORT=5432

# OR using dictionary format
environment:
  DB_HOST: localhost
  DB_PORT: 5432
```

### 4. **Network Configuration**
```bash
# Docker Run
docker run --network mynetwork --network-alias app1 myapp
```
```yaml
# Docker Compose
networks:
  - mynetwork
  
# With network alias
networks:
  mynetwork:
    aliases:
      - app1

# Define custom network at bottom
networks:
  mynetwork:
    driver: bridge
```

### 5. **Container Name**
```bash
# Docker Run
docker run --name my-container nginx
```
```yaml
# Docker Compose
container_name: my-container
```

### 6. **Restart Policy**
```bash
# Docker Run
docker run --restart unless-stopped nginx
```
```yaml
# Docker Compose
restart: unless-stopped
```

### 7. **Working Directory**
```bash
# Docker Run
docker run -w /app nginx
```
```yaml
# Docker Compose
working_dir: /app
```

### 8. **User/Group**
```bash
# Docker Run
docker run --user 1000:1000 nginx
```
```yaml
# Docker Compose
user: "1000:1000"
```

### 9. **Command Override**
```bash
# Docker Run
docker run nginx echo "Hello"
```
```yaml
# Docker Compose
command: echo "Hello"
```

### 10. **Entrypoint Override**
```bash
# Docker Run
docker run --entrypoint /bin/bash nginx
```
```yaml
# Docker Compose
entrypoint: /bin/bash
```

## Multi-Container Example Comparison

**Using Docker Compose (Simple way):**
```yaml
services:
  mysql:
    image: mysql:5.7
    container_name: mysql
    environment:
      MYSQL_ROOT_PASSWORD: secret
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wpuser
      MYSQL_PASSWORD: wppass
    volumes:
      - mysql_data:/var/lib/mysql
    networks:
      - wordpress-network

  wordpress:
    image: wordpress:latest
    container_name: wordpress
    ports:
      - "8080:80"
    environment:
      WORDPRESS_DB_HOST: mysql
      WORDPRESS_DB_USER: wpuser
      WORDPRESS_DB_PASSWORD: wppass
      WORDPRESS_DB_NAME: wordpress
    volumes:
      - wp_content:/var/www/html/wp-content
    depends_on:
      - mysql
    networks:
      - wordpress-network

volumes:
  mysql_data:
  wp_content:

networks:
  wordpress-network:
```

**Run it with one command:**
```bash
docker-compose up -d
```

## What Docker Compose Adds Beyond Docker Run

### 1. **Dependencies & Startup Order**
```yaml
# App waits for database to be ready
depends_on:
  - database
  - redis
```

### 2. **Build Configuration**
```yaml
# Build from Dockerfile instead of using pre-built image
build:
  context: .
  dockerfile: Dockerfile.dev
  args:
    - NODE_ENV=development
```

### 3. **Service Scaling**
```bash
# Run multiple instances
docker-compose up --scale web=3 --scale worker=2
```

### 4. **Unified Configuration**
- Single source of truth
- Version controllable
- Shareable across teams

## Key Advantages of Docker Compose

1. **Simplicity for Multi-Container Apps**
2. **Reproducibility**
3. **Declarative Configuration**
4. **Lifecycle Management:**
```bash
# Easy to manage entire application
docker-compose up    # Start
docker-compose down  # Stop & clean
docker-compose logs  # View logs
docker-compose ps    # Check status
```

## Quick Reference Cheatsheet

| Docker Run Flag    | Docker Compose Equivalent  |
| ------------------ | -------------------------- |
| `-p 80:80`         | `ports: ["80:80"]`         |
| `-v ./data:/app`   | `volumes: ["./data:/app"]` |
| `-e KEY=value`     | `environment: [KEY=value]` |
| `--name myapp`     | `container_name: myapp`    |
| `--network net`    | `networks: [net]`          |
| `--restart always` | `restart: always`          |
| `-d`               | `docker-compose up -d`     |
| `--link container` | `depends_on: [container]`  |
| `-w /app`          | `working_dir: /app`        |
| `--user 1000`      | `user: "1000"`             |