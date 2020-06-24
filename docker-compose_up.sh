#!/usr/bin/env bash

_DIR=$(cd "$(dirname "$0")"; pwd)
cd $_DIR

docker-compose up
