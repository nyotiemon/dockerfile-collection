# mysql

## Running with docker-compose

modify mysql.yaml as you see fit

```shell
# start docker
docker-compose -f mysql.yaml up -d

# stop docker
docker-compose -f mysql.yaml down

# get inside docker
docker exec -it single-mysql_db_1 /bin/bash

# connect mysql client from inside docker
mysql -u nyot -p010203

# connect mysql client from outside docker
mysql -h 0.0.0.0 -P 3309 -u nyot -p010203

```

## Running using docker image

mysql8 with vim installed to config my.cnf

```sh
docker build -f mysql.Dockerfile --tag=mysql8 .
docker run --net=host -p 3309:3309 --name xmysql -d mysql8 --port=3309 --mysqlx-port=33090
docker exec -it xmysql /bin/bash
docker logs xmysql 2>&1 | grep GENERATED
```

more config setup for mysql in docker can be seen here: <https://hub.docker.com/r/mysql/mysql-server/>
