Create a docker container using latest ubuntu image
```Bash
docker run -it --name java_lab ubuntu:latest bash
```

Inside the created container run:
```Bash
apt update
apt install -y default-jdk

mkdir -p /home/app
cd /home/app
```

in ~/app create a java file to **print out "Hello World!"**
```JavaScript
public class HelloWorld{
  public static void main(String[] args){
    System.out.println("HelloWorld");
  }
}
```
compile and run the program
```Bash
javac HelloWorld.java
java HelloWorld
```
Exit the container
```Bash
exit
```
In the Host's terminal
```Bash
docker commit java_lab java-app:1.0
```
this creates a docker image named *java-app* version- 1.0

Images can be converted into a archive file to be shared using
```Bash
docker save -o java-app.tar java-app:1.0
```

The generated archive file can be convered back to a image using
```Bash
docker load -i java-app.tar
```
