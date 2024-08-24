ARG PG_MAJOR=16

FROM postgres:${PG_MAJOR}-alpine AS builder
ARG PG_MAJOR
ARG PGVECTOR_VER="0.7.4"
ARG PGMQ_VER="1.4.2"
ARG POSTGRESML_VER="2e26626"
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
    openblas-dev \
    perl \
    pkgconf \
    postgresql${PG_MAJOR}-dev \
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
RUN tar xf v${PGVECTOR_VER}.tar.gz && \
    cd "pgvector-${PGVECTOR_VER}" && \
    make clean && \
    make OPTFLAGS="" && \
    make install && \
    mkdir -p /usr/share/doc/pgvector && \
    cp LICENSE README.md /usr/share/doc/pgvector

########################
#   tembo-io/pgmq      #
########################
RUN tar xf "v${PGMQ_VER}.tar.gz" && \
    cd "pgmq-${PGMQ_VER}/pgmq-extension" && \
    make && \
    make install

#########################
# postgresml/postgresml #
#########################
#tar xfv postgresml.tar.gz && \
#    cd postgresml-*/pgml-extension && \
RUN git clone --depth=1 --single-branch --recursive https://github.com/postgresml/postgresml && \
    cd postgresml && \
    cargo install cargo-pgrx --version 0.11.2
# cargo install cargo-pgrx --git https://github.com/SamuelMarks/pgrx --branch symbol-redefinition

ENV RUST_BACKTRACE=full
ENV COLORBT_SHOW_HIDDEN=1
RUN cd /tmp/wd/postgresml/pgml-extension && \
    cargo pgrx init
RUN cd /tmp/wd/postgresml/pgml-extension && \
    cargo pgrx install
#   cargo install sqlx-cli --version 0.6.3 && \
#   cargo sqlx database setup

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

# nuclear option in case something was missed
COPY --from=builder /usr/local/lib/postgresql         /usr/local/lib/postgresql
COPY --from=builder /var/lib/postgresql               /var/lib/postgresql
COPY --from=builder /usr/local/share/postgresql       /usr/local/share/postgresql
COPY --from=builder /usr/local/bin/postgres           /usr/local/bin/postgres
COPY --from=builder /usr/local/include/postgresql     /usr/local/include/postgresql
COPY --from=builder /usr/local/include/postgres_ext.h /usr/local/include/
COPY --from=builder /usr/local/bin/postgres           /usr/local/bin/ 

STOPSIGNAL SIGINT

EXPOSE 5432

CMD ["postgres"]
