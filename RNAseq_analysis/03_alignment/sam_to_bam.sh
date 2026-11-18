#!/usr/bin/env bash
set -euo pipefail

samtools view -@ "$3" -b -o "$2" "$1"
