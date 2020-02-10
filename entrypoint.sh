#!/usr/bin/env bash

set -eu

NC='\033[0m' # No Color
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'

npm i -g markdown-link-check

USE_QUITE_MODE="$1"
USE_VERBOSE_MODE="$2"
CONFIG_FILE="$3"

echo "USE_QUITE_MODE: $1"
echo "USE_VERBOSE_MODE: $2"

if [ "$USE_QUITE_MODE" = "yes" ]; then

   if [ "$USE_VERBOSE_MODE" = "yes" ]; then

      if [ -f "$CONFIG_FILE" ]; then
         echo -e "${BLUE}I found config file ${NC}"
         echo -e "${BLUE}Using markdown-link-check configuration file: ${YELLOW}$CONFIG_FILE${NC}"
         find . -name \*.md -not -path "./node_modules/*" -exec markdown-link-check {} --config "$CONFIG_FILE" -vq \; &>> error.txt
      else
         echo -e "${BLUE}Cannot find ${YELLOW}$CONFIG_FILE${NC}"
         echo -e "${YELLOW}NOTE: See https://github.com/tcort/markdown-link-check#config-file-format to know more about"
         echo -e "customizing markdown-link-check by using a configuration file.${NC}"
         find . -name \*.md -not -path "./node_modules/*" -exec markdown-link-check {} -vq \; &>> error.txt
      fi

   else

      if [ -f "$CONFIG_FILE" ]; then
         echo -e "${BLUE}Using markdown-link-check configuration file: ${YELLOW}$CONFIG_FILE${NC}"
         find . -name \*.md -not -path "./node_modules/*" -exec markdown-link-check {} --config "$CONFIG_FILE" -q \; &>> error.txt
      else
         echo -e "${BLUE}Cannot find ${YELLOW}$CONFIG_FILE${NC}"
         echo -e "${YELLOW}NOTE: See https://github.com/tcort/markdown-link-check#config-file-format to know more about"
         echo -e "customizing markdown-link-check by using a configuration file.${NC}"
         find . -name \*.md -not -path "./node_modules/*" -exec markdown-link-check {} -q \; &>> error.txt
      fi

   fi

else

   if [ "$USE_VERBOSE_MODE" = "yes" ]; then

      if [ -f "$CONFIG_FILE" ]; then
         echo -e "${BLUE}Using markdown-link-check configuration file: ${YELLOW}$CONFIG_FILE${NC}"
         find . -name \*.md -not -path "./node_modules/*" -exec markdown-link-check {} --config "$CONFIG_FILE" -v \; &>> error.txt
      else
         echo -e "${BLUE}Cannot find ${YELLOW}$CONFIG_FILE${NC}"
         echo -e "${YELLOW}NOTE: See https://github.com/tcort/markdown-link-check#config-file-format to know more about"
         echo -e "customizing markdown-link-check by using a configuration file.${NC}"
         find . -name \*.md -not -path "./node_modules/*" -exec markdown-link-check {} -v \; &>> error.txt
      fi

   else

      if [ -f "$CONFIG_FILE" ]; then
         echo -e "${BLUE}Using markdown-link-check configuration file: ${YELLOW}$CONFIG_FILE${NC}"
         find . -name \*.md -not -path "./node_modules/*" -exec markdown-link-check {} --config "$CONFIG_FILE" \; &>> error.txt
      else
         echo -e "${BLUE}Cannot find ${YELLOW}$CONFIG_FILE${NC}"
         echo -e "${YELLOW}NOTE: See https://github.com/tcort/markdown-link-check#config-file-format to know more about"
         echo -e "customizing markdown-link-check by using a configuration file.${NC}"
         find . -name \*.md -not -path "./node_modules/*" -exec markdown-link-check {} \; &>> error.txt
      fi

   fi

fi

if [ -e error.txt ] ; then
  if grep -q "ERROR:" error.txt; then
    echo -e "${YELLOW}=========================> MARKDOWN LINK CHECK <=========================${NC}"
    less error.txt
    echo -e "${YELLOW}=========================================================================${NC}"
    exit 113
  fi
else
  echo -e "${GREEN}All good!${NC}"
fi
