FROM fedora:latest

MAINTAINER [Marco Minutoli <marco.minutoli@wsu.edu>]

ENV container docker

# Update the system and install dependencies.
RUN dnf -y update && \
    dnf install -y openssh-server passwd && \
    dnf install -y waf gcc gcc-c++ gdb glibc-devel valgrind gtest-devel gperftools-devel && \
    dnf clean all

# Install systemd and remove things that are not needed.
RUN (cd /lib/systemd/system/sysinit.target.wants/;                              \
    for i in *; do [ $i == systemd-tmpfiles-setup.service ] && rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;                        \
    rm -f /etc/systemd/system/*.wants/*;                                        \
    rm -f /lib/systemd/system/local-fs.target.wants/*;                          \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*;                      \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*;                   \
    rm -f /lib/systemd/system/basic.target.wants/*;                             \
    rm -f /lib/systemd/system/anaconda.target.wants/*;                          \
    rm -f /lib/tmpfiles.d/systemd-nologin.conf;                                 \
    rm -f /var/run/nologin


VOLUME [ "/sys/fs/cgroup", "/tmp", "/run" ]

# Install openssh server.
RUN systemctl enable sshd.service                                               && \
    sed -i '/^session.*pam_loginuid.so/s/^session/# session/' /etc/pam.d/sshd

EXPOSE 22

# Root password and User creat\ion
RUN (echo "root:root" | chpasswd); \
    useradd user && echo "user:user" | chpasswd

# Setup ssh access.
ENV SSHDIR /home/user/.ssh
RUN mkdir -p ${SSHDIR} && chmod -R 600 ${SSHDIR} && \
    chown -R ${USER}:${USER} ${SSHDIR}

CMD ["/usr/sbin/init"]
