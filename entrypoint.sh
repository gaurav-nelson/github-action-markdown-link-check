#!/usr/bin/env bash

set -eu

NC='\033[0m' # No Color
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
USE_QUITE_MODE_INPUT="$1"

echo $(INPUT_USE-QUITE-MODE)
echo $(INPUT_USE-VERBOSE-MODE)
echo $(INPUT_CONFIG-FILE)

npm i -g markdown-link-check

CONFIG_FILE=mlc_config.json

echo -e "${YELLOW}=========================> MARKDOWN LINK CHECK <=========================${NC}"

if [ -f "$CONFIG_FILE" ]; then
    echo -e "${BLUE}Using markdown-link-check configuration file: ${YELLOW}$CONFIG_FILE${NC}"
    if [ "$USE_QUITE_MODE_INPUT" = "yes" ]; then
      find . -name \*.md -not -path "./node_modules/*" -exec markdown-link-check {} --config "$CONFIG_FILE" -q \; 2> error.txt
    else
      find . -name \*.md -not -path "./node_modules/*" -exec markdown-link-check {} --config "$CONFIG_FILE" \; 2> error.txt
    fi
else 
    echo -e "${BLUE}Cannot find ${YELLOW}$CONFIG_FILE${NC}"
    echo -e "${YELLOW}NOTE: See https://github.com/tcort/markdown-link-check#config-file-format to know more about"
    echo -e "customizing markdown-link-check by using a configuration file.${NC}"
    if [ "$USE_QUITE_MODE_INPUT" = "yes" ]; then
      find . -name \*.md -not -path "./node_modules/*" -exec markdown-link-check {} -q \; 2> error.txt
    else
      find . -name \*.md -not -path "./node_modules/*" -exec markdown-link-check {} \; 2> error.txt
    fi
fi

echo -e "${YELLOW}=========================================================================${NC}"

if [ -e error.txt ] ; then
  if grep -q "ERROR:" error.txt; then
    exit 113
  fi
else
  echo -e "${GREEN}All good!${NC}"
fi
