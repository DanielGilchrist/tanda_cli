#!/bin/bash

EXTRA_FLAGS=""
SPEC_ARGS=""

for arg in "$@"; do
	if [[ "$arg" == "--print-output" ]]; then
		EXTRA_FLAGS="$EXTRA_FLAGS -Dprint_output"
	elif [[ "$arg" == -D* ]]; then
		EXTRA_FLAGS="$EXTRA_FLAGS $arg"
	else
		SPEC_ARGS="$SPEC_ARGS $arg"
	fi
done

shards check || shards install && crystal spec -Dtest $EXTRA_FLAGS --error-on-warnings --progress --error-trace $SPEC_ARGS
