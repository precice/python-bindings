# Dockerfile to build a ubuntu image containing the installed Debian package of a release 
ARG branch=develop
ARG from=precice/precice:${branch}
FROM $from

# Installing necessary dependencies
RUN apt-get -qq update && apt-get -qq install \
    apt-utils && \
    apt-get -qq install \
    software-properties-common \
    python3-dev \
    python3-pip && \
    rm -rf /var/lib/apt/lists/*

USER precice

# Upgrade pip to newest version (pip version from 18.04 apt-get is outdated)
RUN python3 -m pip install --user --upgrade pip

# Rebuild image if force_rebuild after that command
ARG CACHEBUST

# Builds the precice python bindings for python3
RUN python3 -m pip install --user https://github.com/precice/python-bindings/archive/$branch.zip