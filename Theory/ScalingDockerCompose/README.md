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