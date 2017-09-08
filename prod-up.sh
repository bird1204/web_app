#!/bin/bash

set -xe

git pull origin master
# docker-compose build
docker-compose -f docker-compose-prod.yml run app bundle exec rails assets:precompile
docker-compose -f docker-compose-prod.yml up -d --force-recreate

