# ARG declarations
ARG IMAGE_TAG_VAL=15.3.0-debian-11-r7
ARG PG_VS_VAL

FROM bitnami/postgresql:${IMAGE_TAG_VAL}

ENV PG_VS=${PG_VS_VAL:-15}
USER root

# General dependencies
RUN useradd -r -u 1002 -g root postgres \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get update -y \
    && apt-get install -y --no-install-recommends wget \
    && wget https://archive.org/download/lsb-compat_9.20161125_amd64/lsb-compat_9.20161125_amd64.deb \
    && apt-get install -y ./lsb-compat_9.20161125_amd64.deb \
    && apt-get install -y --no-install-recommends \
        software-properties-common gpg-agent \
    && apt-get install -y --no-install-recommends g++ gcc git default-libmysqlclient-dev \
    curl tzdata sudo make cmake libpq-dev libclang-dev wget git ca-certificates gpg python3.10 python3-pip

# postgresml dependencies
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && apt-get update -y \
    && . $HOME/.cargo/env

# prep for core
RUN apt-get install -y --no-install-recommends bison build-essential clang flex \
    libopenblas-dev libpython3-dev libreadline-dev libssl-dev pkg-config python3-dev \
    zlib1g-dev libxml2-dev libxslt-dev libxml2-utils xsltproc ccache \
    && cd /tmp \
    && git clone https://github.com/postgresml/postgresml \
    && cd postgresml \
    && git submodule update --init --recursive && cd pgml-extension \
    && pip3 install -r requirements.txt \
    && pip3 install xformers=0.0.20 --no-dependencies
# core
RUN cd /tmp/postgresml/pgml-extension \
    && ~/.cargo/bin/cargo install cargo-pgrx --version "0.9.2" --locked \
    && ~/.cargo/bin/cargo pgrx init && ~/.cargo/bin/cargo pgrx package \
    && cp target/release/pgml-pg${PG_VS}/opt/bitnami/postgresql/lib/* /opt/bitnami/postgresql/lib \
    && cp target/release/pgml-pg${PG_VS}/opt/bitnami/postgresql/share/extension/* /opt/bitnami/postgresql/share/extension \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && cd ~ && rm -rf /tmp/postgresml

# pgvector
RUN cd /tmp \
    && git clone --branch v0.4.1 https://github.com/pgvector/pgvector.git \
    && cd pgvector \
    && make \
    && make install \
    && cd ~ && rm -rf /tmp/pgvector

EXPOSE 5432
USER 1002
ENTRYPOINT [ "/opt/bitnami/scripts/postgresql/entrypoint.sh" ]
CMD [ "/opt/bitnami/scripts/postgresql/run.sh" ]