#!/bin/bash

# Assign port in localhost to 8000 port of container
PORT=$1

if docker images | awk '{print $1}' | grep -w test; then
    docker rmi test
fi

docker build -t test .
docker run -p ${PORT}:8000 test