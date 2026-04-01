# Hands-on Task: Run and Manage a “Hello Web App” (httpd)
## Objective

Deploy and manage a simple Apache-based web server and:

* verify it is running
* modify it
* scale it
* debug it

# Task: Deploy a Simple Web Application (Apache httpd)
## Step 1: Run a Pod

```bash
kubectl run apache-pod --image=httpd
```
![](./createPod.png)

## Step 2: Inspect Pod

```bash
kubectl describe pod apache-pod
```

![](./describePod.png)

## Step 3: Access the App

```bash
kubectl port-forward pod/apache-pod 8081:80
```

Open:

```
http://localhost:8081
```

![](./checkPod.png)

## Step 4: Delete Pod

```bash
kubectl delete pod apache-pod
```

### Insight
* Pod disappears permanently
* No self-healing

---

# Task: Convert to Deployment

## Step 5: Create Deployment

```bash
kubectl create deployment apache --image=httpd
```

![](./createDeployment.png)

## Step 6: Expose Deployment

```bash
kubectl expose deployment apache --port=80 --type=NodePort
```

Access again:

```bash
kubectl port-forward service/apache 8082:80
```

![](./portForwardDeployment.png)

Open:

```
http://localhost:8082
```

![](./checkDeployment.png)

# Task: Modify Behavior

## Step 7: Scale Deployment

```bash
kubectl scale deployment apache --replicas=2
```

![](./scaleDeployment.png)

## Step 8: Test Load Distribution (Basic)

Run port-forward again and refresh browser multiple times.

(Advanced later: logs + different content per pod)

---

# Task: Debugging Scenario

---

## Step 9: Break the App

```bash
kubectl set image deployment/apache httpd=wrongimage
```

Check:

```bash
kubectl get pods
```

---

## Step 10: Diagnose

```bash
kubectl describe pod <pod-name>
```

Look for:

* `ImagePullBackOff`
* error messages

---

## Step 11: Fix It

```bash
kubectl set image deployment/apache httpd=httpd
```

---

# Task: Explore Inside Container (Important Skill)

---

## Step 12: Exec into Pod

```bash
kubectl exec -it <pod-name> -- /bin/bash
```

Now inside container:

```bash
ls /usr/local/apache2/htdocs
```

This is where web files are stored.

Exit:

```bash
exit
```

---

# Task: Observe Self-Healing

---

## Step 13: Delete One Pod

```bash
kubectl delete pod <one-pod-name>
```

Watch:

```bash
kubectl get pods -w
```

---

### Insight

* Deployment recreates pod automatically

---

# Task: Cleanup

```bash
kubectl delete deployment apache
kubectl delete service apache
```

---

# What You Learned (Important)

This task is better than nginx because:

* You accessed actual web output
* You explored container filesystem
* You practiced debugging real errors
* You saw scaling + recovery

---

# Optional Next Challenge 

Modify container at runtime:

```bash
kubectl exec -it <pod-name> -- /bin/bash
```

Then:

```bash
echo "Hello from Kubernetes" > /usr/local/apache2/htdocs/index.html
```

Refresh browser.


---

## Why `kubectl port-forward` blocks the terminal

```
kubectl port-forward pod/apache-pod 8081:80
```

This command is **foreground by design**:

* It opens a **live tunnel** between your local machine and the Pod
* It must stay running to keep the connection active
* It continuously streams data (like a server process)

So the terminal looks “stuck”, but it’s actually **actively maintaining the port-forward session**

---

## Why there is no detached mode

`kubectl port-forward` is meant as a **temporary debugging tool**, not a background service.

Kubernetes expects:

* Short-lived usage
* Manual control (start → debug → stop)

For long-running exposure, Kubernetes provides proper resources:

* `Service` (NodePort / ClusterIP)
* `Ingress`

---

## Running in background using `&`

```
kubectl port-forward pod/apache-pod 8081:80 &
```

This sends the process to the background.

---

## How to identify the process

### Method 1: Using jobs (current terminal)

```
jobs
```

Output example:

```
[1]+  Running   kubectl port-forward pod/apache-pod 8081:80 &
```

---

### Method 2: Using `ps`

```
ps aux | grep port-forward
```

Example output:

```
user   12345  ... kubectl port-forward pod/apache-pod 8081:80
```

Here, `12345` is the **PID (Process ID)**

---

## How to stop the process

### Method 1: Using job number

```
kill %1
```

---

### Method 2: Using PID

```
kill 12345
```

---

### Method 3: Kill all port-forward processes

```
pkill -f port-forward
```

---

## Better approach (recommended)

Instead of `&`, use:

### Option 1: `tmux`

```
tmux new -s pf
kubectl port-forward pod/apache-pod 8081:80
```

Detach:

```
Ctrl + b, d
```

This is cleaner and easier to manage.

---

### Option 2: `nohup`

```
nohup kubectl port-forward pod/apache-pod 8081:80 > pf.log 2>&1 &
```

---

## Summary

* `kubectl port-forward` blocks terminal because it runs a **live network tunnel**
* No detached mode because it is meant for **temporary debugging**
* Use `&`, `jobs`, `ps`, and `kill` to manage background processes
* Prefer `tmux` for better control in DevOps workflows

