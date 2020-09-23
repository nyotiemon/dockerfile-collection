# ------------------------------- 1
sudo docker pull mysql/mysql-server
sudo docker pull mysql/mysql-router
sudo docker pull python
sudo docker network create groupnet

for N in 1 2 3
do sudo docker run -d --name=node$N --net=groupnet --hostname=node$N \
  -v $PWD/d$N:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=1234 mysql/mysql-server \
  --server-id=$N \
  --log-bin='mysql-bin-1.log' \
  --enforce-gtid-consistency='ON' \
  --log-slave-updates='ON' \
  --gtid-mode='ON' \
  --transaction-write-set-extraction='XXHASH64' \
  --binlog-checksum='NONE' \
  --master-info-repository='TABLE' \
  --relay-log-info-repository='TABLE' \
  --plugin-load='group_replication.so' \
  --collation-server='utf8mb4_unicode_ci' \
  --max-connections=2000 \
  --relay-log-recovery='ON' \
  --group-replication-start-on-boot='OFF' \
  --group-replication-single-primary-mode='ON' \
  --group-replication-enforce-update-everywhere-checks='OFF' \
  --group-replication-recovery-get-public-key='ON' \
  --group-replication-group-name='aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee' \
  --group-replication-local-address="node$N:33061" \
  --group-replication-group-seeds='node1:33061,node2:33061,node3:33061' \
--loose-group-replication-ip-whitelist='0.0.0.0/0'
done

sudo docker logs node1
sudo docker logs node2
sudo docker logs node3

sudo docker exec -it node1 mysql -uroot -p1234 \
  -e "CREATE USER IF NOT EXISTS nyot@'%' IDENTIFIED BY '1234';" \
  -e "GRANT ALL PRIVILEGES ON *.* to nyot@'%' WITH GRANT OPTION;" \
  -e "FLUSH PRIVILEGES;" \
  -e "RESET MASTER;"

sudo docker exec -it node2 mysql -uroot -p1234 \
  -e "CREATE USER IF NOT EXISTS nyot@'%' IDENTIFIED BY '1234';" \
  -e "GRANT ALL PRIVILEGES ON *.* to nyot@'%' WITH GRANT OPTION;" \
  -e "FLUSH PRIVILEGES;" \
  -e "RESET MASTER;"

sudo docker exec -it node3 mysql -uroot -p1234 \
  -e "CREATE USER IF NOT EXISTS nyot@'%' IDENTIFIED BY '1234';" \
  -e "GRANT ALL PRIVILEGES ON *.* to nyot@'%' WITH GRANT OPTION;" \
  -e "FLUSH PRIVILEGES;" \
  -e "RESET MASTER;"

# ------------------------------- 2 UPDATE my.cnf value

# ------------------------------- 3 manual
sudo docker exec -it node1 /bin/bash
mysqlsh
shell.connect('nyot@node1')
dba.configureLocalInstance()
dba.configureInstance('nyot@node1')
dba.checkInstanceConfiguration('nyot@node1')
var cluster = dba.createCluster('TESTMGR', {memberWeight:100})
cluster.addInstance('nyot@node2', {memberWeight:90})
cluster.addInstance('nyot@node3', {memberWeight:80})

# ------------------------------- 4 
sudo docker run -d --name=mrouter --net=groupnet -e MYSQL_HOST=node1 -e MYSQL_PORT=3306 -e MYSQL_USER=nyot -e MYSQL_PASSWORD=1234 -e MYSQL_INNODB_NUM_MEMBERS=3 mysql/mysql-router

# ------------------------------- 5 optional
sudo docker exec -it node1 mysql -unyot -p1234 \
  -e "CREATE DATABASE ngetes;" \
  -e "CREATE TABLE testing(data_time DATETIME PRIMARY KEY);"

sudo docker build --tag=pymytest .
sudo docker run -it --name=pytest --net=groupnet pymytest

sudo docker kill node1 node2 node3
sudo docker rm node1 node2 node3 pytest
sudo docker network rm groupnet
sudo docker image rm pymytest mysql/mysql-server mysql/mysql-router python
sudo rm -rf d1 d2 d3
