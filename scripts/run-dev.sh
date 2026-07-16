#!/bin/bash

shards check || shards install && crystal run src/main.cr --progress --error-trace --link-flags=-Wl,-ld_classic --no-debug "$@"
