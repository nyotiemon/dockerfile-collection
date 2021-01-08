#! /bin/bash
echo "Stop and remove old setup"
docker stop ts1 ts2
docker rm ts1 ts2
docker volume rm ts-vol1 ts-vol2
docker network rm ts-net

echo "Build ts"
docker build --rm -t cents .

echo "Create network & volumes"
docker volume create ts-vol1
docker volume create ts-vol2
docker network create ts-net

echo "Starting ts1"
docker run -d --name ts1 -p 5432:5432 --network ts-net \
-v ts-vol1:/var/lib/pgsql/11/data \
--env-file primary.env cents

echo "Starting ts2"
docker run -d --name ts2 -p 5433:5432 --network ts-net \
-v ts-vol2:/var/lib/pgsql/11/data \
--env-file replica.env cents


echo "===================== some notes: =========================
- To get into ts1 system: docker exec -it ts1 /bin/bash
- Instead of using user root, use this way: su postgres
- To connect to db in ts1 : docker exec -it ts1 psql -U postgres"