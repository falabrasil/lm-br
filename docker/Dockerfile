FROM debian:stable-slim

RUN apt-get update && apt-get install -y \
    gcc g++ make aspell aspell-pt libaspell-dev libicu-dev wget time \
    python3 python3-pip pkg-config && \
    pip install pip -U && pip install tqdm num2words pyicu aspell-python-py3

# make sure SRILM has been downloaded and resides in the current dir,
# i.e., the root of this repo
RUN mkdir -p /opt/lm-br /opt/srilm
ADD srilm-1.7.3.tar.gz /opt/srilm
RUN cd /opt/srilm && SRILM=$PWD make -j $(nproc)
ENV PATH="/opt/srilm/bin:/opt/srilm/bin/i686-m64:${PATH}"

COPY . /opt/lm-br/

WORKDIR /opt/lm-br
