#! /bin/bash
echo "Stop and remove old setup"
docker stop ts1 ts2
docker rm ts1 ts2
docker network rm ts-net
docker volume rm ts-vol1 ts-vol2

echo "Build ts"
docker build -t ts1 .
docker build -t ts2 .

echo "Create network & volumes"
docker network create ts-net
docker volume create ts-vol1
docker volume create ts-vol2

echo "Starting ts1"
docker run -d --name ts1 -p 5432:5432 --network ts-net \
-v ts-vol1:/var/lib/postgresql/data \
-e TIMESCALEDB_TELEMETRY=off -e TS_TUNE_MEMORY=1GB -e TS_TUNE_NUM_CPUS=1 \
--env-file primary.env ts1

echo "Starting ts2"
docker run -d --name ts2 -p 5433:5432 --network ts-net \
-v ts-vol2:/var/lib/postgresql/data \
-e TIMESCALEDB_TELEMETRY=off -e TS_TUNE_MEMORY=1GB -e TS_TUNE_NUM_CPUS=1 \
--env-file replica.env ts2

echo "Restart steps are necessary!"
echo "Sleep 3 sec and restart ts2"
sleep 3
docker restart ts2

echo "Sleep 3 sec and restart ts1"
sleep 3
docker restart ts1

echo "Sleep 3 sec and show ts2 logs"
sleep 3
docker logs ts2

echo "===================== some notes: =========================
- To get into ts1 system: docker exec -it ts1 /bin/bash
- Instead of using user root, use this way: su postgres
- To connect to db in ts1 : docker exec -it ts1 psql -U postgres"