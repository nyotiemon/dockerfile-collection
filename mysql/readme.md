# mysql8 with vim installed to config my.cnf
docker build --tag=mysql8 .
docker run --net=host -p 3309:3309 --name xmysql -d mysql8 --port=3309 --mysqlx-port=33090
docker exec -it xmysql /bin/bash
docker logs xmysql 2>&1 | grep GENERATED

# more config setup for mysql in docker can be seen here: https://hub.docker.com/r/mysql/mysql-server/

