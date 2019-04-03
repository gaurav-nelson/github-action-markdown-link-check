#!/usr/bin/env bash

set -eu

npm i -g markdown-link-check

echo "=========================> MARKDOWN LINK CHECK <========================="

find . -name \*.md -not -path "./node_modules/*" -exec markdown-link-check {} \; 2> error.txt

echo "========================================================================="

if [ -e error.txt ] ; then
  if grep -q "ERROR:" error.txt; then
    exit 113
  fi
fi
