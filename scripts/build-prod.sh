#!/bin/bash

crystal build src/tanda_cli.cr --release --no-debug --verbose && mv tanda_cli bin/tanda_cli
