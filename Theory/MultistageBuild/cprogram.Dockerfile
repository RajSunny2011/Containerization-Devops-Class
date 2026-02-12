FROM ubuntu:latest
RUN apt update && apt install -y gcc
COPY app.c .
RUN gcc -static -o app app.c

CMD ["./app"]