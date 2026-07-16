#!/bin/bash

shards check || shards install && crystal run src/main.cr -Draise_errors --progress --error-trace --link-flags=-Wl,-ld_classic "$@"
