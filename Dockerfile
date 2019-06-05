#Base image
FROM ubuntu:16.04

#Labels and Credits
LABEL \
   name="docker-android-kernel" \
   author="Konstantyn Byhkalo <byhkalo.konstantyn@gmail.com>" \
   maintainer="Konstantyn Byhkalo <byhkalo.konstantyn@gmail.com>" \
   contributor_1="Konstantyn Byhkalo <byhkalo.konstantyn@gmail.com>" \
   description="Docker image for building Android common 4.14 kernel."

RUN apt-get update && \
  apt-get install -y bc build-essential make python-lunch qt4-default gcc-multilib distcc ccache

RUN apt install libelf-dev
RUN apt install libelf-devel