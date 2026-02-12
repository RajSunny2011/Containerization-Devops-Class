FROM ubuntu:latest AS builder
RUN apt update && apt install -y gcc
COPY app.c .
RUN gcc -static -o app app.c

FROM scratch
COPY --from=builder ./app ./app
CMD ["./app"]