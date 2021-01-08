#!/bin/bash

DB_PRI=${DB_PRI:-}
PG_CONFDIR="/var/lib/pgsql/11/data"


__run_supervisor() {
supervisord -n
}


__create_user() {
echo "--- create_user"

#Grant rights
usermod -G wheel postgres

echo "Set password_encryption..."
echo "SET password_encryption = 'scram-sha-256';" |
  sudo -u postgres -H /usr/pgsql-11/bin/postgres --single -c config_file=${PG_CONFDIR}/postgresql.conf -D ${PG_CONFDIR}

echo "Creating user repuser..."
echo "CREATE ROLE $REPLICA_POSTGRES_USER WITH REPLICATION PASSWORD '$REPLICA_POSTGRES_PASSWORD' LOGIN;" |
  sudo -u postgres -H /usr/pgsql-11/bin/postgres --single -c config_file=${PG_CONFDIR}/postgresql.conf -D ${PG_CONFDIR}

}


__config_master(){
echo "--- config_master"

echo "Add replication settings to primary postgres conf..."
cat >> ${PG_CONFDIR}/postgresql.conf <<EOF
listen_addresses= '*'
wal_level = replica
max_wal_senders = 3
max_replication_slots = 3
synchronous_commit = off
synchronous_standby_names = '1 (${REPLICA_NAME})'
password_encryption = 'scram-sha-256'

hot_standby = on
archive_mode = on
archive_command = '/bin/true'
EOF

echo "Add replication settings to primary pg_hba.conf..."
if  [[ -z $REPLICATION_SUBNET ]]; then
    REPLICATION_SUBNET=$(getent hosts ${REPLICATE_TO} | awk '{ print $1 }')/32
fi
cat >> ${PGDATA}/pg_hba.conf <<EOF
host     replication     ${REPLICA_POSTGRES_USER}   ${REPLICATION_SUBNET}       scram-sha-256
EOF
}


__config_slave(){
echo "--- config_slave"

# Create a pg pass file so pg_basebackup can send a password to the primary
cat > ~/.pgpass.conf <<EOF
*:5432:replication:${POSTGRES_USER}:${POSTGRES_PASSWORD}
EOF
chown postgres:postgres ~/.pgpass.conf
chmod 0600 ~/.pgpass.conf

# Backup replica from the primary
until PGPASSFILE=~/.pgpass.conf pg_basebackup -h ${REPLICATE_FROM} -D ${PG_CONFDIR} -U ${POSTGRES_USER} -vP -w
do
    # If docker is starting the containers simultaneously, the backup may encounter
    # the primary amidst a restart. Retry until we can make contact.
    sleep 1
    echo "Retrying backup . . ."
done

# Create the recovery.conf file so the backup knows to start in recovery mode
cat > ${PG_CONFDIR}/recovery.conf <<EOF
standby_mode = on
primary_conninfo = 'host=${REPLICATE_FROM} port=5432 user=${POSTGRES_USER} password=${POSTGRES_PASSWORD} application_name=${REPLICA_NAME}'
primary_slot_name = '${REPLICA_NAME}_slot'
EOF

# Ensure proper permissions on recovery.conf
chown postgres:postgres ${PG_CONFDIR}/recovery.conf
chmod 0600 ${PG_CONFDIR}/recovery.conf

}


__config_replication() {
#Grant rights
usermod -G wheel postgres

if [ -n "${DB_PRI}" ]; then
  __config_master
else
  __config_slave
fi

}



# Call all functions
__create_user
__config_replication
__run_supervisor

