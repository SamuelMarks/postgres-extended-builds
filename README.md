postgres extended builds
========================
[![Docker Image Version (tag)](https://img.shields.io/docker/v/samuelmarks/postgres-extended-builds/alpine_latest)](https://hub.docker.com/r/samuelmarks/postgres-extended-builds/tags)
[![docker_build](https://github.com/SamuelMarks/postgres-extended-builds/actions/workflows/docker_build.yml/badge.svg)](https://github.com/SamuelMarks/postgres-extended-builds/actions/workflows/docker_build.yml)

Builds for postgres with many extensions installed and enabled

For Docker images, see: https://hub.docker.com/r/samuelmarks/postgres-extended-builds

## Instructions

```sh
git clone https://github.com/SamuelMarks/postgres-extended-builds
docker build . -f alpine.Dockerfile -t samuelmarks/postgres-extended-builds:alpine_latest
```

And to `push` up to hub.docker.com run:
```sh
docker push samuelmarks/postgres-extended-builds:alpine_latest
```
