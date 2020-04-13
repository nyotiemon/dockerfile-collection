#!/usr/bin/env bash

node_ip="192.168.10.116"

echo "authenticator: PasswordAuthenticator
start_rpc: true
rpc_address: ${node_ip}
broadcast_address: ${node_ip}
broadcast_rpc_address: ${node_ip}
listen_address: ${node_ip}
listen_on_broadcast_address: true
seed_provider:
    - class_name: org.apache.cassandra.locator.SimpleSeedProvider
      parameters:
          - seeds: \"${node_ip}\"" > temp_cas.yaml

echo "JVM_OPTS=\"\$JVM_OPTS -Djava.rmi.server.hostname=127.0.0.1\"
LOCAL_JMX=no" > temp_cas_env.sh

echo "cqlsh ${node_ip} -u cassandra -p cassandra --file \"$HOME/hes-init/hes_init.cql\"" > hes_init.sh

dockerfile='
FROM centos:7 \n
MAINTAINER "Nyoto" <nyoto.arif@ardomusnet.com> \n

ARG USER=nyot \n
ARG NODE_IP=192.168.10.116 \n

RUN yum -y update && yum -y install epel-release && yum -y install python-pip cmake make vim nc git \n
RUN yum -y install build-essential python-devel sudo \n
RUN yum -y install zsh wget java-1.8.0-openjdk \n

RUN chsh -s /bin/zsh \n
RUN sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)" \n
ENV SHELL "/bin/zsh" \n

RUN adduser ${USER} \n
USER ${USER} \n
ENV SHELL "/bin/zsh" \n
WORKDIR /home/${USER}/ \n
RUN git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh \n
RUN cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc \n

USER root \n
COPY ./cassandra.repo /etc/yum.repos.d/ \n
RUN yum -y install cassandra \n
RUN chown -R ${USER}: /var/lib/cassandra \n
RUN chown -R ${USER}: /var/log/cassandra \n
RUN chown -R ${USER}: /etc/cassandra \n
RUN chmod u+w /var/lib/cassandra /var/log/cassandra /etc/cassandra \n

RUN echo JVM_OPTS=\"\$JVM_OPTS -Djava.rmi.server.hostname=127.0.0.1\" >> /etc/cassandra/default.conf/cassandra-env.sh \n
RUN echo LOCAL_JMX=no >> /etc/cassandra/default.conf/cassandra-env.sh \n

RUN mkdir -p /home/${USER}/hes-init/ \n
COPY ./temp_cas_env.sh /home/${USER}/hes-init/ \n
RUN cat /home/${USER}/hes-init/temp_cas_env.sh >> /etc/cassandra/default.conf/cassandra-env.sh \n
COPY ./temp_cas.yaml /home/${USER}/hes-init/ \n
RUN cat /home/${USER}/hes-init/temp_cas.yaml >> /etc/cassandra/conf/cassandra.yaml \n

COPY ../hes_init.cql /home/${USER}/hes-init/ \n
COPY ./hes_init.sh /home/${USER}/hes-init/ \n
RUN chown -R ${USER}: /home/${USER}/hes-init \n
RUN chmod 777 -R /home/${USER}/hes-init/ \n

CMD ["cassandra", "-f"]'

echo -e ${dockerfile} > cassandra-centos
sudo docker build -f cassandra-centos --build-arg USER=${USER} --build-arg NODE_IP=${node_ip} -t icasdb .

# to be used in docker-compose
export UID=$(id -u)
export GID=$(id -g)