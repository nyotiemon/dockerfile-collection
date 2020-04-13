#!/usr/bin/env bash

# https://hub.docker.com/_/cassandra/

PER_DIR=/home/nyot/HES/docker/cassandra/as_image/vol
CONF_DIR=/home/nyot/HES/docker/cassandra/configs
CQL_DIR=/home/nyot/HES/docker/cassandra/cql-files

mkdir -p ${PER_DIR}
mkdir -p ${CONF_DIR}
mkdir -p ${CQL_DIR}

docker pull cassandra:3.11

docker-compose up -d

echo "docker exec -it casdb bash"
echo "docker logs casdb --follow"
echo "docker exec -it casdb cqlsh localhost -u cassandra -p cassandra -e 'describe keyspaces;'"
echo "docker exec -it casdb cqlsh localhost -u cassandra -p cassandra --file '/home/cql-files/hes_init_lite.cql'"
echo "docker exec -it casdb cqlsh localhost -u ardomus -p dogo123"