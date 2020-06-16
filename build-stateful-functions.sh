#!/bin/bash
set -e

basedir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
project_root="${basedir}/../../" # ditch tools/docker
flink_template="${basedir}/flink-distribution-template"

distribution_jar=$(find ${project_root} -type f -name "statefun-flink-distribution*jar" -not -name "*example*")
if [[ -z "${distribution_jar}" ]]; then
	echo "unable to find statefun-flink-distribution jar, please build the maven project first"
	exit 1
fi
core_jar=$(find ${project_root} -type f -name "statefun-flink-core*jar")
if [[ -z "${core_jar}" ]]; then
	echo "unable to find statefun-flink-core jar, please build the maven project first"
	exit 2 
fi

docker_context_root="/tmp/statefun-docker-context"
docker_context_flink="${docker_context_root}/flink"

mkdir -p ${docker_context_flink}
cp -r ${flink_template}/* ${docker_context_flink}/
mkdir -p ${docker_context_flink}/lib
cp ${distribution_jar} ${docker_context_flink}/lib/statefun-flink-distribution.jar
cp ${core_jar} ${docker_context_flink}/lib/statefun-flink-core.jar
# build the docker image
cd ${docker_context_root}
cp ${basedir}/docker-entry-point.sh ${docker_context_root}

