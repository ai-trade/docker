#!/usr/bin/env xonsh

from os.path import dirname,abspath

_DIR=dirname(abspath(__file__))

cd @(_DIR)

template = $(cat docker-compose/template.yml)
from .docker_compose.config import CONFIG
print(template)

