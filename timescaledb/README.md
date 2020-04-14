# Streaming Replication Container Setup for TimescaleDB

[SOURCE](https://github.com/timescale/streaming-replication-docker)

## Running

The containers can either be created through regular Docker commands or through
`Docker Compose` using the `stack.yml` file.

### Run with Docker

After ensuring the variables in `primary.env` and `replica.env` match your
desired configuration, simply run:

```bash
./start_containers.sh
```

### Run with Docker Compose

To run with Docker Compose, run:

```bash
docker build -t timescale-replication .
docker-compose -f stack.yml up
```

## Configuration

Configure various replication settings via the `primary.env` and `replica.env`
files. Whether the replication is synchronous or asynchronous (and to what
degree) can be tuned using the `SYNCRHONOUS_COMMIT` variable in `primary.env`.
The setting defaults to `off`, enabling fully asynchronous streaming
replication. The other valid values are `on`, `local`, `remote_write`, and
`remote_apply`. Consult our [documentation][timescale-streamrep-docs] for
further details about trade-offs (i.e., performance vs. lag time, etc).
