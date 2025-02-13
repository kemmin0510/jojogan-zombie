#!/bin/bash

# Assign port in localhost to 8000 port of container
PORT=$1

# Remove test container and image
docker ps -aq -f name=test | xargs -r docker rm -f

docker images -q test | xargs -r docker rmi -f
docker rmi $(docker images -f "dangling=true" -q)
docker build -t test .

docker run -p ${PORT}:8000 -p 8099:8099 --rm --name test --network jenkins_network test