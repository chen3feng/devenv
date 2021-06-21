# LABEL Author="chen3feng"
# LABEL Version="2020.4"
# LABEL Description="Developer's Image"

FROM ubuntu

ARG DEBIAN_FRONTEND=nointeractive
ENV TZ=Asia/Shanghai

RUN sed -i s@/archive.ubuntu.com/@/mirrors.cloud.tencent.com/@g /etc/apt/sources.list && \
    apt-get -y update && \
    apt-get install -y \
        zsh git git-lfs \
        m4 libtool ninja-build cmake \
        python python3 gcc g++ nasm \
        clang clang-tidy clang-format \
        default-jdk golang \
        man zip zlib1g-dev lzip \
        curl wget \
        vim

#nodejs npm golang rustc default-jdk php subversion ruby clang-format clang-tidy \
# curl -s https://get.sdkman.io | bash sdk install kotlin

RUN apt-get install -y \
        asciinema

RUN apt-get install -y \
        ccache distcc

COPY .bashrc /root/.bashrc
COPY .inputrc /root/.inputrc
COPY .vimrc /root/.vimrc

CMD ["/bin/bash"]

RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && python get-pip.py && \
    pip install coverage

RUN pip install pex
RUN apt-get install -y maven scala
RUN apt-get install -y gdb
