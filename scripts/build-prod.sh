#!/bin/bash

crystal build src/tanda_cli.cr --release --no-debug --progress --stats \
  && mv tanda_cli bin/tanda_cli \
  && echo \
  && printf "\e[32mSuccess:\e[0m compiled release binary to $(pwd)/bin/tanda_cli\n"
