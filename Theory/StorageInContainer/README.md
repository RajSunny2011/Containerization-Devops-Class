# Data Management in Docker with `volume` `bind mount` and `tempfs`

## Problem Statement (Why Data Management?)

Data stored in a container's filesystem will be gone if the container is removed or crashes.

## Solution: Persist Data Outside Container Layer

Docker provides two main approaches of persistance storage:
1. **Volumes**
2. **Bind Mounts**

and one **tmfs** for a temporary memory only filesystem.

## 1. Docker Volumes

A **volume** is a Docker-managed storage location stored under:
```
/var/lib/docker/volumes/
```
Docker controls its lifecycle.

## Task 1: Create a Volume

```bash
docker volume create myvolume
```

### Verify
```bash
docker volume ls
```

## Task 2: Use Volume in Container

### Using `-v` flag
```bash
docker run -d \
  --name mysql-container \
  -v myvolume:/var/lib/mysql \
  mysql
```

### Using `--mount` flag (Recommended Modern Syntax)
```bash
docker run -d \
  --name mysql-container \
  --mount source=myvolume,target=/var/lib/mysql \
  mysql
```

## Task 3: Inspect Volume

```bash
docker volume inspect myvolume
```
Shows:
* Mountpoint
* Driver
* Metadata

## Task 4: Remove Volume

```bash
docker volume rm myvolume
```

Remove unused volumes:
```bash
docker volume prune
```

# 2. Bind Mount

Bind mount maps a **host directory directly** into a container.
Host controls data.

## Task 1: Create Bind Mount

### Using `-v`
```bash
docker run -d \
  --name nginx-container \
  -v /home/prateek/html:/usr/share/nginx/html \
  nginx
```

### Using `--mount`
```bash
docker run -d \
  --name nginx-container \
  --mount type=bind,source=/home/prateek/html,target=/usr/share/nginx/html \
  nginx
```

## Read-Only Bind Mount

## Using `--mount`

```bash
docker run \
  --mount type=bind,source=/home/prateek/html,target=/usr/share/nginx/html,readonly \
  nginx
```

## Using `-v`

```bash
docker run \
  -v /home/prateek/html:/usr/share/nginx/html:ro \
  nginx
```

# Important Rules
1. Always use **absolute path** in bind mount.
2. If host directory does not exist:
   * `-v` may create it automatically
   * `--mount` will fail
3. Bind mount ties container to specific host path (less portable).

* Editing files on host - Changes reflect immediately inside container

## Task 2: Remove Bind Mount

Bind mount is removed when container is removed:

```bash
docker rm -f nginx-container
```

No separate "delete" like volume.

# 3. tmpfs Mount

tmpfs stores data in **RAM only**.

* No persistence
* Deleted when container stops
* Very fast

## Task: Create tmpfs Mount

```bash
docker run -d \
  --name temp-container \
  --mount type=tmpfs,target=/app/cache \
  nginx
```

Or:

```bash
docker run -d \
  --tmpfs /app/cache \
  nginx
```

# Docker Mount Types Comparison

| Feature                               | `type=volume`                                        | `type=bind`               | `type=tmpfs`                    |
| ------------------------------------- | ---------------------------------------------------- | ------------------------- | ------------------------------- |
| Managed by Docker                     | Yes                                                  | No                        | Yes (runtime memory)            |
| Storage Location                      | `/var/lib/docker/volumes/`                           | Any host directory        | RAM (memory)                    |
| Data Persists After Container Removal | Yes                                                  | Yes                       | No                              |
| Depends on Host Directory Structure   | No                                                   | Yes                       | No                              |
| Performance                           | Good                                                 | Depends on host disk      | Very Fast (RAM)                 |
| Editable from Host                    | Not directly (unless you go to Docker internal path) | Yes                       | No                              |
| Suitable for Production               | Yes                                                  | Sometimes (careful usage) | Rarely                          |
| Suitable for Development              | Sometimes                                            | Yes (ideal)               | No                              |
| Data Survives Docker Restart          | Yes                                                  | Yes                       | No                              |
| Risk of Host File Overwrite           | No                                                   | Yes                       | No                              |
| Backup Friendly                       | Yes                                                  | Depends on host           | Not needed                      |
| Typical Use Case                      | Databases, persistent app data                       | Source code, config files | Cache, secrets, temporary files |
