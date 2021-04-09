
FROM debian:buster-slim
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
RUN make install
RUN cd .. && rm -rf gitrepo

VOLUME ["/data"]

WORKDIR /data

CMD ["rethinkdb", "--bind", "all"]

#   process cluster webui
EXPOSE 28015 29015 8080
