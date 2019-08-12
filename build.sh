#!/usr/bin/env bash

docker rmi -f alpine-scala-build-server:1.2.8-alpine3.9
docker rmi -f birchwoodlangham/alpine-scala-build-server:latest

docker build -t birchwoodlangham/alpine-scala-build-server:latest .
