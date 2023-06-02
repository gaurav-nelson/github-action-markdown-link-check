#!/usr/bin/env bash

set -eu

NC='\033[0m' # No Color
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'

npm i -g markdown-link-check@3.11.1
echo "::group::Debug information"
npm -g list --depth=1
echo "::endgroup::"

declare -a FIND_CALL
declare -a COMMAND_DIRS COMMAND_FILES
declare -a COMMAND_FILES

USE_QUIET_MODE="$INPUT_USE_QUIET_MODE"
USE_VERBOSE_MODE="$INPUT_USE_VERBOSE_MODE"
CONFIG_FILE="$INPUT_CONFIG_FILE"
FOLDER_PATH="$INPUT_FOLDER_PATH"
MAX_DEPTH="$INPUT_MAX_DEPTH"
CHECK_MODIFIED_FILES="$INPUT_CHECK_MODIFIED_FILES_ONLY"
BASE_BRANCH="$INPUT_BASE_BRANCH"
if [ -z "$INPUT_FILE_EXTENSION" ]; then
   FILE_EXTENSION=".md"
else
   FILE_EXTENSION="$INPUT_FILE_EXTENSION"
fi
FILE_PATH="$INPUT_FILE_PATH"

if [ -f "$CONFIG_FILE" ]; then
   echo -e "${BLUE}Using markdown-link-check configuration file: ${YELLOW}$CONFIG_FILE${NC}"
else
   echo -e "${BLUE}Cannot find ${YELLOW}$CONFIG_FILE${NC}"
   echo -e "${YELLOW}NOTE: See https://github.com/tcort/markdown-link-check#config-file-format to know more about"
   echo -e "customizing markdown-link-check by using a configuration file.${NC}"
fi

FOLDERS=""
FILES=""

echo -e "${BLUE}USE_QUIET_MODE: $USE_QUIET_MODE${NC}"
echo -e "${BLUE}USE_VERBOSE_MODE: $USE_VERBOSE_MODE${NC}"
echo -e "${BLUE}FOLDER_PATH: $FOLDER_PATH${NC}"
echo -e "${BLUE}MAX_DEPTH: $MAX_DEPTH${NC}"
echo -e "${BLUE}CHECK_MODIFIED_FILES: $CHECK_MODIFIED_FILES${NC}"
echo -e "${BLUE}FILE_EXTENSION: $FILE_EXTENSION${NC}"
echo -e "${BLUE}FILE_PATH: $FILE_PATH${NC}"

handle_dirs () {

   IFS=', ' read -r -a DIRLIST <<< "$FOLDER_PATH"

   for index in "${!DIRLIST[@]}"
   do
      if [ ! -d "${DIRLIST[index]}" ]; then
         echo -e "${RED}ERROR [✖] Can't find the directory: ${YELLOW}${DIRLIST[index]}${NC}"
         exit 2
      fi
      COMMAND_DIRS+=("${DIRLIST[index]}")
   done
   FOLDERS="${COMMAND_DIRS[*]}"

}

handle_files () {

   IFS=', ' read -r -a FILELIST <<< "$FILE_PATH"

   for index in "${!FILELIST[@]}"
   do
      if [ ! -f "${FILELIST[index]}" ]; then
         echo -e "${RED}ERROR [✖] Can't find the file: ${YELLOW}${FILELIST[index]}${NC}"
         exit 2
      fi
      if [ "$index" == 0 ]; then
         COMMAND_FILES+=("-wholename ${FILELIST[index]}")
      else
         COMMAND_FILES+=("-o -wholename ${FILELIST[index]}")
      fi
   done
   FILES="${COMMAND_FILES[*]}"

}

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

add_options () {

   if [ -f "$CONFIG_FILE" ]; then
      FIND_CALL+=('--config' "${CONFIG_FILE}")
   fi

   if [ "$USE_QUIET_MODE" = "yes" ]; then
      FIND_CALL+=('-q')
   fi

   if [ "$USE_VERBOSE_MODE" = "yes" ]; then
      FIND_CALL+=('-v')
   fi

}

check_additional_files () {

   if [ -n "$FILES" ]; then
      if [ "$MAX_DEPTH" -ne -1 ]; then
         FIND_CALL=('find' ${FOLDERS} '-type' 'f' '(' ${FILES} ')' '-not' '-path' './node_modules/*' '-maxdepth' "${MAX_DEPTH}" '-exec' 'markdown-link-check' '{}')
      else
         FIND_CALL=('find' ${FOLDERS} '-type' 'f' '(' ${FILES} ')' '-not' '-path' './node_modules/*' '-exec' 'markdown-link-check' '{}')
      fi

      add_options

      FIND_CALL+=(';')

      set -x
      "${FIND_CALL[@]}" &>> error.txt
      set +x

   fi

}

if [ -z "$FILE_EXTENSION" ]; then
   FOLDERS="."
else
   handle_dirs
fi

if [ -n "$FILE_PATH" ]; then
   handle_files
fi

if [ "$CHECK_MODIFIED_FILES" = "yes" ]; then

   echo -e "${BLUE}BASE_BRANCH: $BASE_BRANCH${NC}"

   git config --global --add safe.directory '*'

   git fetch origin "${BASE_BRANCH}" --depth=1 > /dev/null
   MASTER_HASH=$(git rev-parse origin/"${BASE_BRANCH}")

   if [ -z "$FOLDERS" ]; then
      FOLDERS="."
   fi

   FIND_CALL=('markdown-link-check')

   add_options

   FOLDER_ARRAY=(${FOLDER_PATH//,/ })
   mapfile -t FILE_ARRAY < <( git diff --name-only --diff-filter=AM "$MASTER_HASH" -- "${FOLDER_ARRAY[@]}")

   for i in "${FILE_ARRAY[@]}"
      do
         if [ "${i##*.}" == "${FILE_EXTENSION#.}" ]; then
            FIND_CALL+=("${i}")
            COMMAND="${FIND_CALL[*]}"
            $COMMAND &>> error.txt || true
            unset 'FIND_CALL[${#FIND_CALL[@]}-1]'
         fi
      done

   check_additional_files

   check_errors

else

   if [ "$MAX_DEPTH" -ne -1 ]; then
      FIND_CALL=('find' ${FOLDERS} '-name' '*'"${FILE_EXTENSION}" '-not' '-path' './node_modules/*' '-maxdepth' "${MAX_DEPTH}" '-exec' 'markdown-link-check' '{}')
   else
      FIND_CALL=('find' ${FOLDERS} '-name' '*'"${FILE_EXTENSION}" '-not' '-path' './node_modules/*' '-exec' 'markdown-link-check' '{}')
   fi

   add_options

   FIND_CALL+=(';')

   set -x
   "${FIND_CALL[@]}" &>> error.txt
   set +x

   check_additional_files

   check_errors

fi
