## **Experiment - 1**: Comparison of Virtual Machines (VMs) and Containers using Ubuntu and Nginx

### **Objective**
1. To understand the conceptual and practical differences between Virtual Machines and Containers.

2. To install and configure a Virtual Machine using VirtualBox and Vagrant on Windows.

3. To install and configure Containers using Docker inside WSL.

4. To deploy an Ubuntu-based Nginx web server in both environments.

5. To compare resource utilization, performance, and operational characteristics of VMs and Containers.


### **Part A: Virtual Machine**

 - Download Vagrantfile of required VM OS using `vagrant init hashicorp/bionic64`, run `vagrant up` to start up the VM and `vagrant ssh` to access the VM terminal.

![](./vagrant-init.png)
![](./vagrant-up.png)
![](./vagrant-ssh.png)

 - Install nginx using `sudo apt install -y nginx` and run the service using `sudo systemctl start nginx`. Verify it by `curl localhost`.

![](./vm-setup-1.png)
![](./vm-setup-2.png)
![](./vm-setup-3.png)

#### **Observations**
**1. Storage Utilization:** The disk usage for the VM.
```PS
VBoxManage showmediuminfo <path/to/virtualdrive>
```
![](./vm-size.png)
  
> The VM installation consumed approximately **1773 MB** of disk space to store the Guest OS and virtual disk.

**2. Boot Performance:** The startup time required for the Virtual Machine to boot.
```bash
systemd-analyze
```
![](./vm-boot-time.png)
> The VM took **27.049 seconds** to fully boot (Kernel: 6.634s + Userspace: 20.414s), demonstrating high startup latency.

**3. Memory Usage:** Amount of RAM resources allocated to and used by the Guest OS.

```bash
free -h
```
![](./vm-memory-usage.png)

> The VM reserved **985 MB** of total RAM from the host, with *73 MB* actively used and 670 MB used up in buffers/cache.

### **Part B: Containers**

 - Run the `docker run -d -p 8080:80 --name nginx-container nginx` command to create and run the container. Verify that the nginx container is running wih `curl localhost:8080`.

    - `-d`: Runs the container in the background, allowing you to continue using the terminal session.
    - `-p 8080:80`: Maps port 8080 for the host to port 80 for the container.

![](./docker-nginx-run.png)
![](./docker-curl.png)

#### **Observations**
**1. Storage Utilization**
An analysis of the disk space required for the container images.

```bash
docker images
```

![](./docker-images.png)

> The Nginx container image requires only **161 MB**.

**2. Boot Performance**
Measurement of the time required to start the containerized application.

```bash
time docker run -d -p 8080:80 --name nginx-container nginx
```
![](./docker-time-run.png)

> The container started in **0.428 seconds**.

**3. Memory Allocation**
Real-time monitoring of the container's resource consumption.

```bash
docker stats
```
![](./docker-stats.png)

> The running container uses **13.14 MiB** of RAM.

### **Comparison**

| Metric | Virtual Machine | Container | Difference |
| :--- | :--- | :--- | :--- |
| **Disk Usage** | **~1.8 GB** | **161 MB** | Containers are *smaller* because they do not require a full Guest OS copy. |
| **Boot Time** | **27.05s** | **0.43s**  | Containers start *faster* by leveraging the already-running Host Kernel. |
| **Memory** | **~985 MB** Reserved / *73 MB* Used | **13.14 MB** Used | VMs reserve a fixed block of RAM; Containers use only what the process needs dynamically. |
| **Architecture** | **Hardware Virtualization** (Guest OS) | **OS Virtualization** (Shared Kernel) | VMs run a full isolated OS; Containers run as isolated processes on the Host OS. |
