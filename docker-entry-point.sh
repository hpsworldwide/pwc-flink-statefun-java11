#!/bin/bash 

WORKER="worker"
MASTER="master"

#
# Environment
# 
FLINK_HOME=${FLINK_HOME:-"/opt/flink/bin"}
ROLE=${ROLE:-"worker"}
MASTER_HOST=${MASTER_HOST:-"localhost"}

#
# Start a service depending on the role.
#
if [[ "${ROLE}" == "${WORKER}" ]]; then
  #
  # start the TaskManager (worker role)
  #
  exec ${FLINK_HOME}/bin/taskmanager.sh start-foreground \
    -Djobmanager.rpc.address=${MASTER_HOST}

elif [[ "${ROLE}" == "${MASTER}" ]]; then
  #
  # start the JobManager (master role) with our predefined job.
  #
  exec $FLINK_HOME/bin/standalone-job.sh \
    start-foreground \
    -Djobmanager.rpc.address=${MASTER_HOST} \
   "$@"
else
  #
  # unknown role
  #
  echo "unknown role ${ROLE}"
  exit 1
fi
