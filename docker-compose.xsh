#!/usr/bin/env xonsh
import sys
from os.path import dirname,abspath,join
from mako.template import Template

_DIR=dirname(abspath(__file__))
sys.path.insert(0, _DIR)

from docker_compose_config import CONFIG

COMPOSE_DIR = join(_DIR, "docker-compose")
cd @(COMPOSE_DIR)
template = Template($(cat template.yml))

def main():
  for image, user_dict in CONFIG.items():
    for user,port in user_dict.items():
      mkdir -p @(user)
      outpath = f"{COMPOSE_DIR}/{user}/docker-compose.yml"
      print(outpath)
      with open(outpath,"w") as out:
        out.write(
          template.render(
            image=image,
            port=port*100,
            user=user
          )
        )

if __name__ == "__main__":
  main()
