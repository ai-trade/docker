#!/usr/bin/env bash

cd $(dirname "$0")
./build.sh
docker push renwucool/dev

