#!/bin/bash

crystal build src/tanda_cli.cr --release --no-debug && mv tanda_cli bin/tanda_cli
