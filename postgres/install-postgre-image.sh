#!/usr/bin/env bash

PER_DIR=/home/nyot/HES/docker/postgre/vol
# PG_PASSWORD=specialdogcomingby
# DB_USER=ardomus
# DB_PASSWORD=randomdogwalkedby
# DB_NAME=hes

docker pull sameersbn/postgresql:10-2

mkdir -p ${PER_DIR}

echo "run docker-compose up -d"
docker-compose up -d

# SELinux users should update the security context of the host mountpoint so that it plays nicely with Docker:
# chcon -Rt svirt_sandbox_file_t ./pgsql

# docker run --name pgdb -itd --restart always \
#     --publish 5432:5432 \
#     --volume ${PER_DIR}:/var/lib/postgresql \
#     --env 'PG_TRUST_LOCALNET=true' \
#     --env 'PG_PASSWORD=${PG_PASSWORD}' \
#     --env 'DB_USER=${DB_USER}' --env 'DB_PASS=${DB_PASSWORD}' --env 'DB_NAME=${DB_NAME}' \
#     sameersbn/postgresql:10-2

# docker exec -it pgdb sudo -u postgres psql
# docker exec -it pgdb bash
# docker exec -it pgdb psql -h localhost -U postgres -d postgres -c 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp";'
# psql -h localhost -U ardomus -d ardomus_hes -c '\i init_db.sql'
