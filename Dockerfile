FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
ARG V_REDIS=6.0.9
ARG V_REDISEARCH=2.0.4
ARG V_REDISJSON=1.0.6
ARG V_OPENSSL=1.1.1h

RUN export THREADS=`nproc --all` \
&& apt-get update && apt-get upgrade \
  && apt-get install -y \
    git \
    build-essential \
    libsystemd-dev \
    wget \
    python \
    curl \
    lcov \
    libatomic1 \
    cmake \
    python-psutil \
    rustc \
    pkg-config \
    gcc \
    clang \
    libclang-dev \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir -p /etc/redis/modules \
&& mkdir -p /build && cd /build \
  && wget https://www.openssl.org/source/openssl-${V_OPENSSL}.tar.gz \
  && tar xf openssl-${V_OPENSSL}.tar.gz \
  && cd /build/openssl-${V_OPENSSL} && ./config && make -j${THREADS} && make test && make install \
&& mkdir -p /build && cd /build \
  && git clone --recursive https://github.com/redis/redis.git && cd redis && git checkout ${V_REDIS} \
  && cd /build/redis && make -j${THREADS} BUILD_TLS=yes && make install && cd utils && ./install_server.sh \
  && find / -name redis-server \
&& mkdir -p /build && cd /build \
  && git clone --recursive https://github.com/RediSearch/RediSearch.git && cd RediSearch && git checkout v${V_REDISEARCH} \
  && cd /build/RediSearch && make setup && make -j${THREADS} build \
  && find / -name redisearch.so \
  && cp /build/RediSearch/build/redisearch.so /etc/redis/modules/redisearch.so \
&& mkdir -p /build && cd /build \
  && git clone --recursive https://github.com/RedisJSON/RedisJSON.git && cd RedisJSON && git checkout v${V_REDISJSON} \
  && cd /build/RedisJSON && make -j${THREADS} \
  && find /build/RedisJSON -name *.so \
  && cp /build/RedisJSON/src/rejson.so /etc/redis/modules/rejson.so \
&& apt-get remove -y \
  git \
  build-essential \
  libsystemd-dev \
  wget \
  python \
  curl \
  lcov \
  cmake \
  python-psutil \
  rustc \
  pkg-config \
  gcc \
  clang \
  libclang-dev \
&& apt-get autoremove -y \
&& rm -rf /build

COPY redis.conf /etc/redis/redis.conf

CMD [ "redis-server", "/etc/redis/redis.conf" ]  