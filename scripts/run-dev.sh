#!/bin/bash

crystal run src/tanda_cli.cr --progress --error-trace --link-flags=-Wl,-ld_classic --no-debug "$@"
