FROM maven:3-openjdk-11-slim as flink-statefun-builder

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git && \
    git version

ENV VERSION 2.1.0

RUN git clone https://github.com/apache/flink-statefun.git

WORKDIR /flink-statefun
RUN git checkout release-$VERSION && \
    mvn clean package -DskipTests

ADD build-stateful-functions.sh /flink-statefun/tools/docker
WORKDIR /flink-statefun/tools/docker
RUN chmod +x ./build-stateful-functions.sh && \
    ./build-stateful-functions.sh

########################################################################################################################
FROM hpsworldwide/pwc-flink-java11:1.10.1 as flink-statefun-runner

ENV ROLE worker
ENV MASTER_HOST localhost
ENV STATEFUN_HOME /opt/statefun
ENV STATEFUN_MODULES $STATEFUN_HOME/modules

RUN rm -fr $FLINK_HOME/lib/flink-table*jar

COPY --from=flink-statefun-builder /tmp/statefun-docker-context/flink/ $FLINK_HOME/
COPY --from=flink-statefun-builder /tmp/statefun-docker-context/docker-entry-point.sh /docker-entry-point.sh

USER root

RUN mkdir -p $STATEFUN_MODULES && \
    useradd --system --home-dir $STATEFUN_HOME --uid=9998 --gid=flink statefun && \
    chown -R statefun:flink $STATEFUN_HOME && \
    chmod -R g+rw $STATEFUN_HOME && \
    chmod +x /docker-entry-point.sh

RUN wget --quiet https://download-gcdn.ej-technologies.com/jprofiler/jprofiler_linux_11_1_4.tar.gz -P /tmp/ && \
    tar -xzf /tmp/jprofiler_linux_11_1_4.tar.gz -C /opt && \
    rm /tmp/jprofiler_linux_11_1_4.tar.gz && \
    mv /opt/jprofiler11.1.4 /opt/jprofiler

ENTRYPOINT ["/docker-entry-point.sh"]
