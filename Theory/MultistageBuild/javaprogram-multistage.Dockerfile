FROM eclipse-temurin:17-jdk AS builder
WORKDIR /app
COPY HelloWorld.java .
RUN javac HelloWorld.java

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=builder ./app/HelloWorld.class .
CMD ["java", "HelloWorld"]