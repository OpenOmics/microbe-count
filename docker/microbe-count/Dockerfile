# Base image for microbe-count,
# uses noble as base image
FROM ubuntu:24.04

# Depedencies of microbe-count include:
#  • kraken2        build from source, github install: 2.17.1
#  • bracken        build from source, github install: 2.9
#  • centrifuger    build from source, github install: 1.1.1
#  • samtools       apt-get, installs: 1.19.2-1
#  • python3        apt-get, installs: 3.12.3-0
#  • multiqc        installed from pypi, installs: 1.35
#  • taxpasta       installed from pypi, installs: 0.7.1
#  • fastqc         apt-get, installs: 0.12.1
LABEL maintainer=kuhnsa@nih.gov

############### INIT ################
# Create Container filesystem specific
# working directory and opt directories
# to avoid collisions with the host's
# filesystem, i.e. /opt and /data
RUN mkdir -p /opt2 && mkdir -p /data2
WORKDIR /opt2

# Set time zone to US east coast
ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
        && echo $TZ > /etc/timezone

############### SETUP ################
# This section installs system packages
# required for your project. If you need
# extra system packages add them here.
RUN apt-get update \
    && apt-get -y upgrade \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        build-essential \
        bzip2 \
        ca-certificates \
        cmake \
        curl \
        fastqc \
        gawk \
        git \
        gzip \
        locales \
        make \
        ncbi-blast+ \
        perl \
        python3 \
        python3-pip \
        python3-pandas \
        rsync \
        samtools \
        sed \
        unzip \
        wget \
        zlib1g-dev \
    && apt-get clean && apt-get purge \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set the locale
RUN localedef -i en_US -f UTF-8 en_US.UTF-8

# Make python3 the default interpreter
# and install Python Packages, this installs
# the latest version of taxpasta. The latest
# release of taxpasta (i.e 0.7.0) is not
# compatiable with python 3.12, so we install
# it from github using pip.
RUN ln -sf /usr/bin/python3 /usr/bin/python \
        && pip3 install --break-system-packages multiqc==1.35 git+https://github.com/taxprofiler/taxpasta.git@a9b2e581a0a97fc5e836b21a6bc4ae7cd94a96ad

############### INSTALL ################
# Install GNU which, increases compatiability
# with which distros included with Debian/Rocky
# linux installations, this version of which
# includes extra options that the ubuntu version
# does not have. The gnu verison is backwards
# compatiable with the ubunutu version.
RUN mkdir -p /opt2 \
        && wget --no-check-certificate -O /opt2/which.tar.gz https://ftp.gnu.org/gnu/which/which-2.21.tar.gz \
        && tar -xvf /opt2/which.tar.gz -C /opt2/ \
        && rm /opt2/which.tar.gz \
        && cd /opt2/which-2.21 \
        && ./configure --prefix=/opt2/which-2.21 \
        && make \
        && make install

# Install the latest release of
# kraken2 from Github, the current
# apt version of kraken2 (i.e 2.1.3)
# contains a bug that causes bracken
# to error out during execution
RUN cd /opt2 \
        && wget https://github.com/DerrickWood/kraken2/archive/refs/tags/v2.17.1.tar.gz -O /opt2/kraken2.tar.gz \
        && tar -xvf /opt2/kraken2.tar.gz -C /opt2/ \
        && rm /opt2/kraken2.tar.gz \
        && cd /opt2/kraken2-2.17.1 \
        && mkdir /opt2/kraken2-2.17.1/bin \
        && /opt2/kraken2-2.17.1/install_kraken2.sh /opt2/kraken2-2.17.1/bin/

# Install centrifuger from Github,
# checkout the latest commit hash
# for reproducibility, this has a
# bug fix for printing help/usage
# info without a core dump:
# https://github.com/mourisl/centrifuger
RUN cd /opt2 \
        && git clone https://github.com/mourisl/centrifuger.git /opt2/centrifuger-d561b2a \
        && cd /opt2/centrifuger-d561b2a/ \
        && git checkout d561b2aa37e36a8f003801e4b20a15ebbfa92df3 \
        && rm -rf /opt2/centrifuger-d561b2a/.git \
        && make

# Install bracken from Github,
# https://github.com/jenniferlu717/Bracken
RUN cd /opt2 \
        && wget https://github.com/jenniferlu717/Bracken/archive/refs/tags/v2.9.tar.gz -O /opt2/bracken.tar.gz \
        && tar -xvf /opt2/bracken.tar.gz -C /opt2/ \
        && rm /opt2/bracken.tar.gz \
        && cd /opt2/Bracken-2.9/ \
        && /opt2/Bracken-2.9/install_bracken.sh

################ POST #################
# Add Dockerfile and export important
# environment variables
ADD Dockerfile /opt2/microbe-count_0-1-0.dockerfile
RUN chmod -R a+rX /opt2
ENV PATH="/opt2/which-2.21/bin:/opt2/kraken2-2.17.1/bin:/opt2/centrifuger-d561b2a:/opt2/Bracken-2.9:/opt2/Bracken-2.9/src:${PATH}"
WORKDIR /data2
