#!/bin/bash

set -e

SCRIPT=$(realpath -s $0)
SCRIPT_DIR=$(dirname ${SCRIPT})

CONTAINER=${1:-test-centos-8}

docker-compose -p otrs-ce-installer run --rm "${CONTAINER}" \
    /otrs-ce-installer/main.sh
