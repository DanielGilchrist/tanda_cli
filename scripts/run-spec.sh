#!/bin/bash

shards install && crystal spec -Dtest --no-debug --error-on-warnings --progress --error-trace
