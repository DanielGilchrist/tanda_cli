#!/bin/bash

shards check || shards install && crystal spec -Dtest --no-debug --error-on-warnings --progress --error-trace -- $1
