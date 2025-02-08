#!/bin/bash

# Assign port in localhost to 8000 port of container
PORT=$1

if docker ps -a | awk '{print $1}' | grep -w test; then
    docker stop test
    docker rm test
fi

if docker images | awk '{print $1}' | grep -w test; then
    docker rmi -f test
fi

docker build -t test .
docker run -d -p ${PORT}:8000 --rm --name test test