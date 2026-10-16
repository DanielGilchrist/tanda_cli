#!/bin/sh
if [ -n "$TANDA_CLI_SPEC_EDITOR_CAPTURE" ]; then cp "$1" "$TANDA_CLI_SPEC_EDITOR_CAPTURE"; fi
printf '%s\n' "$TANDA_CLI_SPEC_EDITOR_CONTENT" > "$1"
