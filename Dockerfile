FROM openjdk:8u191-jdk-alpine

# NOTE: bash is used by scala/scalac scripts and cannot be easily rep;aced with Ash
RUN apk add --no-cache --virtual=build-dependencies wget ca-certificates && \
    apk add --no-cache bash git && \
    wget https://piccolo.link/sbt-1.2.8.tgz && \
    tar -C /usr/local -xf sbt-1.2.8.tgz && \
    ln -s /usr/local/sbt/bin/sbt /usr/local/bin/sbt && \
    chmod 0755 /usr/local/bin/sbt && \
    rm sbt-1.2.8.tgz && \
    apk del build-dependencies

RUN mkdir /build

ADD install/credentials /root/.sbt/.credentials
ADD scripts/* /

ENTRYPOINT [ "/entrypoint.sh" ]

CMD ["/build.sh"]
