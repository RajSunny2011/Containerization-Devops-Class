This Dockerfile starts with the *ubuntu:22.04* image and add our own changes.
```Dockerfile
FROM ubuntu:22.04 # Start from ubuntu:22.04 image
RUN apt update && apt install -y default-jdk # Run apt update and install jdk
WORKDIR /home/app # Directory to work in 
COPY HelloWorld.java . # Copy given from current dir 
RUN javac HelloWorld.java
CMD {"java", "HelloWorld"}
```

This command converts Dockerfile in current directory into a image.
```Bash
docker build -t java-app:1.0 .
```
