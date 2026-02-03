FROM ubuntu
RUN apt update && apt install -y default-jdk
WORKDIR /home/app
COPY HelloWorld.java .
RUN javac HelloWorld.java
CMD ["echo", "HELLO from V2"]
