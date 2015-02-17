#!/bin/bash

set -e

cd ${BUILD_DIR}

wrapdocker &
sleep 5

docker -v make

