FROM timescale/timescaledb:latest-pg11

ADD replication.sh /docker-entrypoint-initdb.d/

RUN apk update && \
    apk add curl vim git make

# RUN curl /var https://install.citusdata.com/community/rpm.sh | /bin/bash

# RUN apk add postgresql-11-repmgr
