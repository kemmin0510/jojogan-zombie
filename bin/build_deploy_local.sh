#!/bin/bash

# Assign port in localhost to 8000 port of container
PORT=$1

# Remove test container and image
docker ps -aq -f name=test | xargs -r docker rm -f
docker images -q test | xargs -r docker rmi -f

docker build -t test .
docker run -d -p ${PORT}:8000 --rm --name test --network jenkins_network test