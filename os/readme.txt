

# ubuntu18
docker build --tag=ubuntu18 .
docker run -it -d --net=host --name=ubuntu1 ubuntu18
docker exec -it ubuntu1 /bin/bash

# centos7
docker build --tag=centos7 .
docker run -it -d --net=host --name=mycentos centos7
docker exec -it mycentos /bin/bash

