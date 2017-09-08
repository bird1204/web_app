# README

## Prerequisite

- [docker](https://docs.docker.com/engine/installation/)

## Local development

```sh
$ docker-compose up -d
$ docker attach 'your-container-name'
```

[local](http://127.0.0.1:3000/)

### Enable cache

```sh
$ touch tmp/caching-dev.txt
$ docker-compose restart
```

## Run unit test

```sh
$ docker-compose run app bundle exec rails test
```

## Production

List of configurable environment varirables

- RAILS_ENV: production
- RAILS_SERVE_STATIC_FILES: 'true'
- SECRET_KEY_BASE: your-key

