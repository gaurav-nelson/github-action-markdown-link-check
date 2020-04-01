#!/usr/bin/env bash

set -eu

NC='\033[0m' # No Color
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'

npm i -g markdown-link-check

USE_QUIET_MODE="$1"
USE_VERBOSE_MODE="$2"
CONFIG_FILE="$3"
FOLDER_PATH="$4"

echo -e "${BLUE}USE_QUIET_MODE: $1${NC}"
echo -e "${BLUE}USE_VERBOSE_MODE: $2${NC}"
echo -e "${BLUE}FOLDER_PATH: $4${NC}"

FIND_CALL="find ${FOLDER_PATH} -name \*.md -not -path './node_modules/*' -exec markdown-link-check {}"

if [ -f "$CONFIG_FILE" ]; then
   if [ "$USE_QUIET_MODE" = "yes" ]; then
      if [ "$USE_VERBOSE_MODE" = "yes" ]; then
         echo -e "${BLUE}I found config file ${NC}"
      fi
   fi
   echo -e "${BLUE}Using markdown-link-check configuration file: ${YELLOW}$CONFIG_FILE${NC}"
   FIND_CALL+=" --config ${CONFIG_FILE}"
else
   echo -e "${BLUE}Cannot find ${YELLOW}$CONFIG_FILE${NC}"
   echo -e "${YELLOW}NOTE: See https://github.com/tcort/markdown-link-check#config-file-format to know more about"
   echo -e "customizing markdown-link-check by using a configuration file.${NC}"
fi

if [ "$USE_QUIET_MODE" = "yes" ]; then
   FIND_CALL+=" -q"
fi

if [ "$USE_VERBOSE_MODE" = "yes" ]; then
   FIND_CALL+=" -v"
fi

FIND_CALL+=" \; &>> error.txt"

set -x
echo "$FIND_CALL" | sh
set +x

if [ -e error.txt ] ; then
  if grep -q "ERROR:" error.txt; then
    echo -e "${YELLOW}=========================> MARKDOWN LINK CHECK <=========================${NC}"
    cat error.txt
    printf "\n"
    echo -e "${YELLOW}=========================================================================${NC}"
    exit 113
  else
    echo -e "${YELLOW}=========================> MARKDOWN LINK CHECK <=========================${NC}"
    printf "\n"
    echo -e "${GREEN}[✔] All links are good!${NC}"
    printf "\n"
    echo -e "${YELLOW}=========================================================================${NC}"
  fi
else
  echo -e "${GREEN}All good!${NC}"
fi
