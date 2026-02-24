# Scaling WordPress with Docker Compose

# Docker Compose Scaling

## Basic Scaling Command Explained

```bash
docker compose up --scale web=3 --scale worker=2
```
- **`up`** - Creates and starts containers
- **`--scale web=3`** - Runs 3 instances of the `web` service

## Example 1: Simple Web + Worker Setup

### docker-compose.yml
```yaml
services:
  web:
    image: nginx:latest
    ports:
      - "8080-8082:80"  # Dynamic port mapping for scaling
    networks:
      - app-network

  worker:
    image: alpine:latest
    command: sh -c "while true; do echo 'Working...'; sleep 5; done"
    networks:
      - app-network

  redis:
    image: redis:alpine
    networks:
      - app-network

networks:
  app-network:
```

### Running the Scale Command
Start with 3 web and 2 worker instances
```bash
docker compose up --scale web=3 --scale worker=2 -d
```

Check running containers
```bash
docker compose ps
```

### Port Assignment
| Container | Host Port | Container Port |
| --------- | --------- | -------------- |
| web-1     | 8080      | 80             |
| web-2     | 8081      | 80             |
| web-3     | 8082      | 80             |

## Important Scaling Concepts

### 1. **What Gets Scaled?**
- Stateless services (like web servers or background workers) do not store persistent data locally, scale them horizontally without issues.
- Stateful services (like databases) maintain persistent data. Running multiple instances without proper coordination can lead to data inconsistencies or conflicts.
```yaml
services:
  web:          # Can scale - stateless
    image: nginx
  
  worker:       # Can scale - stateless
    image: python
  
  database:     # Don't scale - stateful
    image: postgres # or other database
    volumes:    # Volume conflict if scaled
      - data:/var/lib/postgresql/data
```

### 2. **Port Handling Strategies**

#### **Dynamic Port Range**
```yaml
ports:
  - "3000-3005:3000"  # Docker assigns available ports
```
#### **Random Port Range**
```yaml
ports:
  - "3000"  # Docker assigns available ports randomly based on availability
```

#### **No Ports (Internal Only)**
```yaml
expose:
  - "3000"  # Internal access only, great for scaling
```

#### **Single Port (Not Scalable)**
```yaml
ports:
  - "8080:80"  # Can't scale beyond 1 instance
```

### 3. **Network Communication**
```yaml
# All scaled instances can reach each other by service name
backend:
  image: myapp
  command: curl http://backend:3000  # Load balanced across all backend instances
```
## Commands Reference

```bash
# Scale specific services
docker compose up --scale web=3 --scale worker=2 -d

# Scale all services (with defaults)
docker compose up --scale web=3 -d  # others stay at 1

# View scaled services
docker compose ps

# View logs from all instances
docker compose logs -f

# Scale down
docker compose up --scale web=1 -d

# Stop everything
docker compose down
```

## Key Takeaways

| Aspect                 | Rule                 | Example                            |
| ---------------------- | -------------------- | ---------------------------------- |
| **Stateless Services** | Scale freely         | web, api, worker                   |
| **Stateful Services**  | Don't scale          | databases, queues                  |
| **Port Mapping**       | Use ranges or expose | `8080-8085:80` or `expose: - "80"` |
| **Service Discovery**  | Use service names    | `database:5432` works for all      |
| **Data Sharing**       | Use volumes          | All instances share same data      |





# From last session

Extent `Wordpress + MySQL`  for scaling with reverse proxy



## The Original Setup `Wordpress + MySQL`  (Not Scalable)

```yaml
# Original docker-compose.yml
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
    ports:                    # Problem: Fixed host port
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

## Scaling Challenges
### Challenge 1: Port Conflict
```bash
$ docker compose up --scale wordpress=3
# ERROR: Bind for 0.0.0.0:8080 failed: port is already allocated
```

### Challenge 2: MySQL Can't Scale
```bash
$ docker compose up --scale mysql=2
# ERROR: Volume conflict - multiple containers can't share mysql_data
```
**Why?** MySQL needs clustering (Galera, Group Replication) for scaling.

## The Scalable Solution
### Step 1: Remove Port Mapping, Use Expose
```yaml
wordpress:
  image: wordpress:latest
  expose:                    # Internal access only
    - "80"
  # ports: - "8080:80"       # Removed
```

### Step 2: Add Nginx Reverse Proxy
```yaml
nginx:
  image: nginx:latest
  ports:
    - "8080:80"              # Single entry point
  volumes:
    - ./nginx.conf:/etc/nginx/nginx.conf
  depends_on:
    - wordpress
  networks:
    - wordpress-network
```

### Step 3: Create Nginx Configuration (nginx.conf)
```nginx
events {}

http {
    upstream wordpress {
        server wordpress:80;  # Docker DNS resolves to all replicas
    }

    server {
        listen 80;
        location / {
            proxy_pass http://wordpress;
            proxy_set_header Host $host;
        }
    }
}
```

## Final Scalable docker-compose.yml

```yaml
services:
  mysql:
    image: mysql:latest
    container_name: mysql
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: wordpress
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
    volumes:
      - mysql_data:/var/lib/mysql
    networks:
      - wordpress-network

  wordpress:
    image: wordpress:latest
    expose:
      - "80"
    environment:
      WORDPRESS_DB_HOST: mysql
      WORDPRESS_DB_USER: ${MYSQL_USER}
      WORDPRESS_DB_PASSWORD: ${MYSQL_PASSWORD}
      WORDPRESS_DB_NAME: wordpress
    volumes:
      - wp_content:/var/www/html/wp-content
    depends_on:
      - mysql
    networks:
      - wordpress-network

  nginx:
    image: nginx:latest
    ports:
      - "8080:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - wordpress
    networks:
      - wordpress-network

volumes:
  mysql_data:
  wp_content:

networks:
  wordpress-network:
```

## Scaling Commands

```bash
# Scale WordPress to 3 instances
$ docker compose up --scale wordpress=3

# Verify
$ docker compose ps
```

## Architecture Overview

```
User Request
    ↓
Port 8080 (Host)
    ↓
Nginx (Load Balancer)
    ↓
wordpress-1 ─┐
wordpress-2 ─┼─→ MySQL (Single Instance)
wordpress-3 ─┘
    ↓
Shared Volume: wp_content (Media, Plugins, Themes)
```