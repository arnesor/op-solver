FROM arneso/ubuntu-cplex:2211 AS builder

RUN apt-get update && apt install -y \
    autoconf \
    automake \
    build-essential \
    git \
    libgmp-dev \
    libtool \
    m4 \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 https://github.com/arnesor/op-solver.git

RUN cd op-solver \
    && ./autogen.sh \
    && mkdir -p build \
    && cd build \
    && ../configure --with-cplex=/opt/ibm/ILOG/CPLEX_Studio_Community2211/cplex \
    && make \
    && make install \
    && git clone --depth 1 https://github.com/bcamath-ds/OPLib.git


FROM ubuntu:latest
ENV LD_LIBRARY_PATH=/usr/local/lib/
COPY --from=builder /usr/local/ /usr/local/
COPY --from=builder /op-solver/build/OPLib/ /OPLib/
WORKDIR /tmp
ENTRYPOINT ["/usr/local/bin/op-solver"]
