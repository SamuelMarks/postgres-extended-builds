ARG PG_MAJOR=16

FROM postgres:${PG_MAJOR}-alpine AS builder
ARG PG_MAJOR
ARG PG_VECTOR="0.7.4"
ARG PGMQ_VER="1.4.2"

RUN apk add --no-cache build-base clang15 llvm15 postgresql${PG_MAJOR}-dev

WORKDIR /tmp/wd

ADD "https://github.com/pgvector/pgvector/archive/refs/tags/v${PG_VECTOR}.tar.gz" .
ADD "https://github.com/tembo-io/pgmq/archive/refs/tags/v${PGMQ_VER}.tar.gz" .

#########################
#   pgvector/pgvector   #
#########################
RUN tar xf v${PG_VECTOR}.tar.gz && \
    cd /tmp/wd/pgvector-${PG_VECTOR} && \
    make clean && \
    make OPTFLAGS="" && \
    make install && \
    mkdir -p /usr/share/doc/pgvector && \
    cp LICENSE README.md /usr/share/doc/pgvector && \
    cd /tmp/wd && \
########################
#   tembo-io/pgmq      #
########################
    tar xf v${PGMQ_VER}.tar.gz && \
    cd /tmp/wd/pgmq-${PGMQ_VER}/pgmq-extension && \
    make && \
    make install

FROM postgres:${PG_MAJOR}-alpine AS runner
ARG PG_MAJOR
ARG PG_VECTOR="0.7.4"
ARG PGMQ_VER="1.4.2"

# pgvector
COPY --from=builder /usr/share/doc/pgvector                        /usr/share/doc/pgvector
COPY --from=builder /usr/local/lib/postgresql/bitcode              /usr/local/lib/postgresql/bitcode
COPY --from=builder /usr/local/share/postgresql/extension          /usr/local/share/postgresql/extension
COPY --from=builder /usr/local/include/postgresql/server/extension /usr/local/include/postgresql/server/extension

# nuclear option in case something was missed
COPY --from=builder /usr/share/doc/pgvector           /usr/share/doc/pgvector
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
