ARG PG_MAJOR=16

FROM postgres:${PG_MAJOR}-alpine AS builder
ARG PG_MAJOR
ARG PGVECTOR=1
ARG PGVECTOR_VER="0.7.4"
ARG PGMQ=1
ARG PGMQ_VER="1.4.2"
ARG POSTGRESML=0
ARG POSTGRESML_VER="52dba30" # Mon Aug 26 13:18:28 2024 -0700
ARG PGAI=1
ENV PGRX_HOME='/opt/pgrx'

RUN apk add --no-cache \
    bison \
    build-base \
    cargo \
    clang15 \
    cmake \
    flex \
    git \
    linux-headers \
    llvm15 \
    make \
    openblas-dev \
    perl \
    pkgconf \
    "postgresql${PG_MAJOR}-plpython3" \
    # be careful with this one^
    "postgresql${PG_MAJOR}-dev" \
    py3-pip \
    python3-dev \
    readline-dev \
    tzdata \
    zlib-dev

WORKDIR /tmp/wd

ADD "https://github.com/pgvector/pgvector/archive/refs/tags/v${PGVECTOR_VER}.tar.gz" .
ADD "https://github.com/tembo-io/pgmq/archive/refs/tags/v${PGMQ_VER}.tar.gz" .
ADD "https://api.github.com/repos/postgresml/postgresml/tarball/${POSTGRESML_VER}" "postgresml.tar.gz"

#########################
#   pgvector/pgvector   #
#########################
RUN if [ "${PGVECTOR}" -eq 1 ]; then \
      tar xf v${PGVECTOR_VER}.tar.gz && \
      cd "pgvector-${PGVECTOR_VER}" && \
      make clean && \
      make OPTFLAGS="" && \
      make install && \
      mkdir -p /usr/share/doc/pgvector && \
      cp LICENSE README.md /usr/share/doc/pgvector ; \
    fi

########################
#   tembo-io/pgmq      #
########################
RUN if [ "${PGMQ}" -eq 1 ]; then \
      tar xf "v${PGMQ_VER}.tar.gz" && \
      cd "pgmq-${PGMQ_VER}/pgmq-extension" && \
      make && \
      make install ; \
    fi

#########################
# postgresml/postgresml #
#########################
#tar xfv postgresml.tar.gz && \
#    cd postgresml-*/pgml-extension && \
ENV RUST_BACKTRACE=full
ENV COLORBT_SHOW_HIDDEN=1
RUN if [ "${POSTGRESML}" -eq 1 ]; then \
      git clone --depth=1 --single-branch --recursive https://github.com/postgresml/postgresml && \
      cd postgresml && \
      cargo install cargo-pgrx --version 0.11.2 && \
      cargo pgrx init && \
      cargo pgrx install ; \
    fi

#########################
# postgresml/postgresml #
#########################
#tar xfv postgresml.tar.gz && \
#    cd postgresml-*/pgml-extension && \
ENV RUST_BACKTRACE=full
ENV COLORBT_SHOW_HIDDEN=1
RUN if [ "${POSTGRESML}" -eq 1 ]; then \
      git clone --depth=1 --single-branch --recursive https://github.com/postgresml/postgresml && \
      cd postgresml && \
      cargo install cargo-pgrx --version 0.11.2 && \
      cargo pgrx init && \
      cargo pgrx install ; \
    fi
# cargo install cargo-pgrx --git https://github.com/SamuelMarks/pgrx --branch symbol-redefinition

#   cargo install sqlx-cli --version 0.6.3 && \
#   cargo sqlx database setup

#########################
#    timescale/pgai     #
#########################
# dependencies: pgvector
RUN if [[ "${PGAI}" -eq 1 && "${PGVECTOR}" -eq 1 ]]; then \
      git clone --depth=1 --single-branch https://github.com/timescale/pgai && \
      python3 -m venv /opt/venv && . /opt/venv/bin/activate && \
      cd pgai && \
      make install ; \
    fi

FROM postgres:${PG_MAJOR}-alpine AS runner
ARG PG_MAJOR
ARG PGVECTOR_VER="0.7.4"
ARG PGMQ_VER="1.4.2"
ENV PGRX_HOME='/opt/pgrx'

# pgvector
COPY --from=builder /usr/share/doc/pgvector                        /usr/share/doc/pgvector
COPY --from=builder /usr/local/lib/postgresql/bitcode              /usr/local/lib/postgresql/bitcode
COPY --from=builder /usr/local/share/postgresql/extension          /usr/local/share/postgresql/extension
COPY --from=builder /usr/local/include/postgresql/server/extension /usr/local/include/postgresql/server/extension

# postgresml
# COPY --from=builder "${PGRX_HOME}" "${PGRX_HOME}"

# pgai
COPY --from=builder /tmp/wd/pgai                                    /tmp/wd/pgai
COPY --from=builder /usr/local/lib/pgai                             /usr/local/lib/pgai

# nuclear option in case something was missed
COPY --from=builder /usr/local/lib/postgresql                       /usr/local/lib/postgresql
COPY --from=builder /var/lib/postgresql                             /var/lib/postgresql
COPY --from=builder /usr/local/share/postgresql                     /usr/local/share/postgresql
COPY --from=builder /usr/local/bin/postgres                         /usr/local/bin/postgres
COPY --from=builder /usr/local/include/postgresql                   /usr/local/include/postgresql
COPY --from=builder /usr/local/include/postgres_ext.h               /usr/local/include/
COPY --from=builder /usr/local/bin/postgres                         /usr/local/bin/
COPY --from=builder /usr/lib/"postgresql${PG_MAJOR}"                /usr/lib/"postgresql${PG_MAJOR}"
COPY --from=builder /usr/lib/libpython3*                            /usr/lib/

RUN apk add --no-cache python3-dev "postgresql${PG_MAJOR}-plpython3"

STOPSIGNAL SIGINT

EXPOSE 5432


ENV PYTHONPATH="/opt/venv/lib/python3.12/site-packages"
ENV VIRTUAL_ENV="/opt/venv"

CMD ["postgres"]
