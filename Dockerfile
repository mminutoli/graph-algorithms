FROM fedora:latest

MAINTAINER [Marco Minutoli <marco.minutoli@wsu.edu>]

ENV container docker

# Update the system.
RUN dnf -y update && dnf clean all

# Install systemd and remove things that are not needed.
RUN dnf -y install systemd && dnf clean all && \
(cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

VOLUME [ "/sys/fs/cgroup", "/tmp", "/run" ]

# Install openssh server.
RUN dnf install -y openssh-server passwd && dnf clean all && \
    systemctl enable sshd.service;\
    sed -i '/^session.*pam_loginuid.so/s/^session/# session/' /etc/pam.d/sshd;\
    rm -f /lib/tmpfiles.d/systemd-nologin.conf


RUN echo "root:root" | chpasswd
EXPOSE 22

# Create user.
RUN useradd user && echo "user:user" | chpasswd

# Setup ssh access.
ENV SSHDIR /home/user/.ssh
RUN mkdir -p ${SSHDIR}

RUN chmod -R 600 ${SSHDIR}* && \
    chown -R ${USER}:${USER} ${SSHDIR}

# Installing dependencies
RUN dnf install -y \
  waf \
  gcc \
  gcc-c++ \
  gdb \
  glibc-devel \
  valgrind \
  gtest-devel \
  gperftools-devel &&  dnf clean all

CMD ["/usr/sbin/init"]
