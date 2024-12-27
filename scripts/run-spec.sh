#!/bin/bash

shards check || shards install && crystal spec -Dtest --error-on-warnings --progress --error-trace -- $1
