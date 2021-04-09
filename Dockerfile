
FROM debian:buster-slim as builder
ARG TAG=next
RUN apt-get -qqy update \
    && apt-get install -y g++ protobuf-compiler libprotobuf-dev \
                     libboost-dev curl m4 wget libssl-dev git \
                     clang llvm make ca-certificates gnupg2 python \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/rethinkdb/rethinkdb gitrepo
WORKDIR /gitrepo

RUN git checkout ${TAG}
RUN ./configure --allow-fetch CXX=clang++
RUN make -j4
RUN make install
RUN cd .. && rm -rf gitrepo

FROM debian:buster-slim

RUN apt-get -qqy update \
    && apt-get install -y --no-install-recommends ca-certificates gnupg2 libprotobuf-dev \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/bin/rethinkdb /usr/local/bin/
COPY --from=builder /usr/local/share/man/man1/rethinkdb.1.gz /usr/local/share/man/man1/
COPY --from=builder /usr/local/share/doc/rethinkdb /usr/local/share/doc/rethinkdb
COPY --from=builder /usr/local/etc/init.d/rethinkdb /usr/local/etc/init.d/rethinkdb
COPY --from=builder /usr/local/var/lib/rethinkdb /usr/local/var/lib/rethinkdb
COPY --from=builder /usr/local/etc/rethinkdb /usr/local/etc/rethinkdb

VOLUME ["/data"]

WORKDIR /data

CMD ["rethinkdb", "--bind", "all"]

#   process cluster webui
EXPOSE 28015 29015 8080
