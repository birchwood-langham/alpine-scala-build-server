#!/usr/bin/env bash

docker rmi -f alpine-scala-build-server:1.2.8-alpine3.9

docker build -t alpine-scala-build-server:1.2.8-alpine3.9 .
