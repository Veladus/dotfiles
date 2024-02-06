#!/bin/bash
xinput | awk '/(SYNA|ELAN)/ {split($5, a, "="); print a[2]}' | xargs -I {} xinput disable {}
