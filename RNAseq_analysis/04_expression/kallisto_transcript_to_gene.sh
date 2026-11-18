#!/usr/bin/env bash
set -euo pipefail

RSCRIPT="$1"
GTF="$2"
ABUNDANCE="$3"
OUTPUT="$4"

mkdir -p "$(dirname "$OUTPUT")"
Rscript "$RSCRIPT" "$GTF" "$ABUNDANCE" "$OUTPUT"
