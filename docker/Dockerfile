FROM i386/ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    bc \
    bison \
    build-essential \
    ca-certificates \
    file \
    flex \
    libncurses5-dev \
    lzop \
    make \
    u-boot-tools \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /work
