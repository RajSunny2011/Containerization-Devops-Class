FROM ubuntu:22.04
RUN apt update && apt install -y default-jdk
WORKDIR /home/app
COPY HelloWorld.java .
RUN javac HelloWorld.java
CMD {"java", "HelloWorld"}

