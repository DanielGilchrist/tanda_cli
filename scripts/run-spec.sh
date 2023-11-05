#!/bin/bash

crystal spec -Dtest --no-debug --error-on-warnings --progress --error-trace --link-flags=-Wl,-ld_classic
