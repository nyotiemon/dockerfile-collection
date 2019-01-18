

# ubuntu18
docker build --tag=ubuntu18 .
docker run -it -d --net=host --name=ubuntu1 ubuntu18
docker exec -it ubuntu1 /bin/bash

# centos7
docker build --tag=centos7 .
docker run -it -d --net=host --name=mycentos centos7
docker exec -it mycentos /bin/bash

# mysql8 with vim installed to config my.cnf
docker build --tag=mysql8 .
docker run --net=host -p 3309:3309 --name xmysql -d mysql8 --port=3309 --mysqlx-port=33090
docker exec -it xmysql /bin/bash