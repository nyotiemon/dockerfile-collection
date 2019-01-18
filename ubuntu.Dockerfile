FROM ubuntu:18.04
RUN apt-get update && apt-get install locales

# Set the locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN useradd -ms /bin/bash tony
RUN echo 'tony:1234' | chpasswd
RUN usermod -aG sudo tony

# sshd
RUN apt-get update && apt-get install openssh-server -y
RUN mkdir /var/run/sshd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# Install dependencies
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y wget unzip build-essential cmake gcc libcunit1-dev libudev-dev net-tools vim screen sudo

RUN apt-get update && apt-get install build-essential python-dev openssl libssl-dev libevent-dev git libkrb5-dev ntp lsb-release -y

# install nodejs 8.x
# RUN wget -qO- https://deb.nodesource.com/setup_8.x | sudo -E bash -
# RUN apt-get update && apt-get install -y nodejs

# install zmq
# RUN apt-get update && apt-get install -y libtool pkg-config build-essential autoconf automake uuid-dev libkrb5-dev
# RUN wget https://github.com/zeromq/libzmq/releases/download/v4.2.2/zeromq-4.2.2.tar.gz && tar xvzf zeromq-4.2.2.tar.gz && cd zeromq-4.2.2 && ./configure && make install

# install mysql
# RUN wget https://dev.mysql.com/get/mysql-apt-config_0.8.11-1_all.deb && dpkg -i mysql-apt-config_0.8.11-1_all.deb && apt-get update && apt-get install -y mysql-server