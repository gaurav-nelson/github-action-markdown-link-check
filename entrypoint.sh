#!/usr/bin/env bash

set -eu

NC='\033[0m' # No Color
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'

npm i -g markdown-link-check@3.8.1

declare -a FIND_CALL

USE_QUIET_MODE="$1"
USE_VERBOSE_MODE="$2"
CONFIG_FILE="$3"
FOLDER_PATH="$4"
MAX_DEPTH="$5"
CHECK_MODIFIED_FILES="$6"
BASE_BRANCH="$7"
FILE_EXTENSION="$8"

echo -e "${BLUE}USE_QUIET_MODE: $1${NC}"
echo -e "${BLUE}USE_VERBOSE_MODE: $2${NC}"
echo -e "${BLUE}FOLDER_PATH: $4${NC}"
echo -e "${BLUE}MAX_DEPTH: $5${NC}"
echo -e "${BLUE}CHECK_MODIFIED_FILES: $6${NC}"
echo -e "${BLUE}FILE_EXTENSION: $8${NC}"

check_errors () {
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
}

if [ "$CHECK_MODIFIED_FILES" = "yes" ]; then

   echo -e "${BLUE}BASE_BRANCH: $7${NC}"

   git fetch origin "${BASE_BRANCH}" --depth=1 > /dev/null
   MASTER_HASH=$(git rev-parse origin/"${BASE_BRANCH}")

   FIND_CALL=('markdown-link-check')

   if [ -f "$CONFIG_FILE" ]; then
      echo -e "${BLUE}Using markdown-link-check configuration file: ${YELLOW}$CONFIG_FILE${NC}"
      FIND_CALL+=('--config' "${CONFIG_FILE}")
   else
      echo -e "${BLUE}Cannot find ${YELLOW}$CONFIG_FILE${NC}"
      echo -e "${YELLOW}NOTE: See https://github.com/tcort/markdown-link-check#config-file-format to know more about"
      echo -e "customizing markdown-link-check by using a configuration file.${NC}"
   fi

   if [ "$USE_QUIET_MODE" = "yes" ]; then
      FIND_CALL+=('-q')
   fi

   if [ "$USE_VERBOSE_MODE" = "yes" ]; then
      FIND_CALL+=('-v')
   fi

   mapfile -t FILE_ARRAY < <( git diff --name-only "$MASTER_HASH" )

   for i in "${FILE_ARRAY[@]}"
      do
         if [ ${i: -3} = ".md" ]; then
            FIND_CALL+=("${i}")
            COMMAND="${FIND_CALL[@]}"
            $COMMAND &>> error.txt || true
            unset 'FIND_CALL[${#FIND_CALL[@]}-1]'
         fi
      done
   
   check_errors

else

   if [ "$5" -ne -1 ]; then
      FIND_CALL=('find' "${FOLDER_PATH}" '-name' '*'"${FILE_EXTENSION}" '-not' '-path' './node_modules/*' '-maxdepth' "${MAX_DEPTH}" '-exec' 'markdown-link-check' '{}')
   else
      FIND_CALL=('find' "${FOLDER_PATH}" '-name' '*'"${FILE_EXTENSION}" '-not' '-path' './node_modules/*' '-exec' 'markdown-link-check' '{}')
   fi

   if [ -f "$CONFIG_FILE" ]; then
      echo -e "${BLUE}Using markdown-link-check configuration file: ${YELLOW}$CONFIG_FILE${NC}"
      FIND_CALL+=('--config' "${CONFIG_FILE}")
   else
      echo -e "${BLUE}Cannot find ${YELLOW}$CONFIG_FILE${NC}"
      echo -e "${YELLOW}NOTE: See https://github.com/tcort/markdown-link-check#config-file-format to know more about"
      echo -e "customizing markdown-link-check by using a configuration file.${NC}"
   fi

   if [ "$USE_QUIET_MODE" = "yes" ]; then
      FIND_CALL+=('-q')
   fi

   if [ "$USE_VERBOSE_MODE" = "yes" ]; then
      FIND_CALL+=('-v')
   fi

   FIND_CALL+=(';')

   set -x
   "${FIND_CALL[@]}" &>> error.txt
   set +x
   check_errors

fi
