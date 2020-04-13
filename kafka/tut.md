# Kafka

## shell

- into kafka docker: docker exec -it kafka-confluent_kafka1_1 /bin/bash
- kafka related shell dir loc: /usr/bin/
- to list topics: docker exec -it DOCKERNAME kafka-topics [--zookeeper zoo1:2181|--bootstrap-server 127.0.0.1:9092] --list
- to create topic: docker exec -it DOCKERNAME kafka-topics --zookeeper zoo1:2181 --create --topic TOPICNAME --replication-factor 2 --partitions 3
- to describe topic info: docker exec -it DOCKERNAME kafka-topics --bootstrap-server 127.0.0.1:9092 --describe meterdata

## Q&A

- hotspot due to partition leader? say there are 5 brokers and 10 topics, each with 5 partitions. not all partition leader will be in broker#1, it will be spread across all broker, therefore load balancing.
- quorum, ack, and leader election? no quorum but ISR(in-sync replica), there will be N-replicas that need to be in same state as leader. if leader is down, the next leader will be among ISR node. if all node die, then the first replica to recover will be leader. producer marked success write if all ISR too.
- Is Zookeeper a must for Kafka? Yes. [Read this](https://stackoverflow.com/questions/23751708/is-zookeeper-a-must-for-kafka).
- What's ZK for? Controller election, configuring topics, ACL, etc. Check source: role of zookeper
- num of consumer should <= partition? In a Customer Group=yes. But there can be multi CG, which each CG will get the same amount of data, with their own offset mark. See **kafka-consumer-concepts**
- how long is message retention before it get deleted permanently from log? by default 1 week (168hr)

## source

- [kafka-confluent-docker](https://github.com/simplesteph/kafka-stack-docker-compose)
- [kafka-python](https://kafka-python.readthedocs.io/en/master/apidoc/KafkaAdminClient.html)
- [kafka-doc](http://kafka.apache.org/documentation/#gettingStarted)
- [kafka-consumer-info](https://www.confluent.io/blog/tutorial-getting-started-with-the-new-apache-kafka-0-9-consumer-client/)
- [kafka-consumer-concepts](https://www.oreilly.com/library/view/kafka-the-definitive/9781491936153/ch04.html)
- [kafka-partition-info](https://www.confluent.io/blog/how-choose-number-topics-partitions-kafka-cluster/)
- [kafka-replication](https://www.confluent.io/blog/hands-free-kafka-replication-a-lesson-in-operational-simplicity/)
- [role of zookeper](https://data-flair.training/blogs/zookeeper-in-kafka/)
