# based on https://github.com/CentOS/CentOS-Dockerfiles/tree/master/postgres/centos7

FROM centos:7

RUN yum -y update; yum clean all
RUN yum -y install sudo epel-release vim wget git; yum clean all

RUN wget https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm && \
    rpm -i pgdg-redhat-repo-latest.noarch.rpm && \ 
    yum -y install postgresql11-server postgresql11 postgresql-contrib supervisor pwgen && \
    yum clean all

# install timescaledb
ADD ./timescale_timescaledb.repo /etc/yum.repos.d/timescale_timescaledb.repo
RUN yum -y update && \
    yum -y install timescaledb-postgresql-11

# update psql
RUN mv /usr/bin/psql /usr/bin/psql-bk && \
    ln -s  /usr/pgsql-11/bin/psql /usr/bin/psql

ADD ./postgresql-setup /usr/bin/postgresql-setup
ADD ./supervisord.conf /etc/supervisord.conf
ADD ./start_postgres.sh /start_postgres.sh

# Sudo requires a tty. fix that.
RUN sed -i 's/.*requiretty$/#Defaults requiretty/' /etc/sudoers
RUN chmod +x /usr/bin/postgresql-setup
RUN chmod +x /start_postgres.sh

RUN /usr/bin/postgresql-setup initdb

EXPOSE 5432

CMD ["/bin/bash", "/start_postgres.sh"]
