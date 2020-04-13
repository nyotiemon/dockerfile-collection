FROM centos:7
RUN yum -y update; yum clean all

# misc
RUN yum -y install https://centos7.iuscommunity.org/ius-release.rpm

ENV container=docker
RUN yum -y install systemd initscripts epel-release; yum clean all; \
(cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

VOLUME [ “/sys/fs/cgroup” ]
CMD [“/usr/sbin/init”]

RUN yum -y install yum-utils wget vim openssl python36u python36u-pip python36u-devel

RUN wget https://dev.mysql.com/get/mysql80-community-release-el7-1.noarch.rpm
RUN yum localinstall mysql80-community-release-el7-1.noarch.rpm -y
RUN yum -y update && yum -y install mysql-community-server