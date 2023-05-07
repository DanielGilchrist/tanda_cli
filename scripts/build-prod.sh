#!/bin/bash

# This script assumes you're running it from the root of the project
# i.e. ./scripts/build-prod.sh

crystal build src/tanda_cli.cr --release --no-debug --progress --stats \
  && mv tanda_cli bin/tanda_cli \
  && echo \
  && printf "\e[32mSuccess:\e[0m compiled release binary to $(pwd)/bin/tanda_cli\n"
