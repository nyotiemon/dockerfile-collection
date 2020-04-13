# How-to Cassandra

## Tutorial

[Cassandra Tutorial for Beginners](https://www.guru99.com/cassandra-tutorial.html)

[Cassandra Documentation](http://cassandra.apache.org/doc/latest/cql/index.html)

[Remotely accessible Cassandra #1](https://stackoverflow.com/questions/36133127/how-to-configure-cassandra-for-remote-connection)
[Remotely accessible Cassandra #2](https://stackoverflow.com/questions/31706818/jmx-is-not-enabled-to-receive-remote-connection)
[Remotely accessible Cassandra #3](https://stackoverflow.com/questions/20690987/apache-cassandra-unable-to-gossip-with-any-seeds)

## Running this

1. run `install-cassandra-in-centos.sh`
2. run `docker-compose up -d`
3. run `docker exec -it casdb zsh`
4. inside container, wait several sec, then run `./hes-init/hes_init.sh`
5. run `cqlsh ${IP_ADDRESS} -u ${USER} -p ${PASSWORD} -k ardomus_hes -e "describe loadprofile;"`
6. to run cqlsh from outside of container, run `cqlsh ${IP_ADDRESS} --cqlversion="3.4.4" -u ${USER} -p ${PASSWORD} -k ardomus_hes -e "describe loadprofile;"`
