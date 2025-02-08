#!/bin/bash

if docker images | awk '{print $1}' | grep -w test; then
    docker rmi test
fi
docker build -t test .
docker run --rm -p 8005:8000 -v ./app:/app/app test