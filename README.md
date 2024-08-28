postgres extended builds
========================
[![Docker Image Version (tag)](https://img.shields.io/docker/v/samuelmarks/postgres-extended-builds/alpine_latest)](https://hub.docker.com/r/samuelmarks/postgres-extended-builds/tags)
[![docker_build](https://github.com/SamuelMarks/postgres-extended-builds/actions/workflows/docker_build.yml/badge.svg)](https://github.com/SamuelMarks/postgres-extended-builds/actions/workflows/docker_build.yml)

Builds for postgres with many extensions installed and enabled. Currently:

| Extension                                                         | Description                                           |
| ----------------------------------------------------------------- | ----------------------------------------------------- |
| [pgvector/pgvector](https://github.com/pgvector/pgvector)         | Vector similarity search for Postgres                 |
| [tembo-io/pgmq](https://github.com/tembo-io/pgmq)                 | Lightweight message queue                             |
| [postgresml/postgresml](https://github.com/postgresml/postgresml) | Postgres with GPUs for ML/AI apps                     |
| [timescale/pgai](https://github.com/timescale/pgai)               | pgai brings embedding and generation AI models closer |

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

---

<small>

## License

Licensed under either of

- Apache License, Version 2.0 ([LICENSE-APACHE](LICENSE-APACHE) or <https://www.apache.org/licenses/LICENSE-2.0>)
- MIT license ([LICENSE-MIT](LICENSE-MIT) or <https://opensource.org/licenses/MIT>)

at your option.

### Contribution

Unless you explicitly state otherwise, any contribution intentionally submitted
for inclusion in the work by you, as defined in the Apache-2.0 license, shall be
dual licensed as above, without any additional terms or conditions.

</small>
