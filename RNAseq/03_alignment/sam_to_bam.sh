#!/usr/bin/env bash

samtools view -@ "$3" -b -o "$2" "$1"
