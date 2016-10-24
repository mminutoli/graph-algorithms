FROM phusion/baseimage

MAINTAINER [Marco Minutoli <marco.minutoli@wsu.edu>]

CMD ["/sbin/my_init"]

RUN useradd user && echo "user:user" | chpasswd
RUN mkdir /develop && chown -R user:user /develop

RUN apt-get update && apt-get install -y --no-install-recommends \
build-essential \
cmake \
gdb \
valgrind \
libgtest-dev \
libgoogle-perftools-dev \
libtcmalloc-minimal4 \
python

# Install gtest
RUN cd /usr/src/gtest && cmake . && make && cp libgtest* /usr/lib/

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
