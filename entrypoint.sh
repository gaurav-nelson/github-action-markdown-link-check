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

declare -a COMMANDS
declare -a FOLDERS
declare -a EXCLUDE_DIRS
declare -a EXCLUDE_FILES

USE_QUIET_MODE="$1"
USE_VERBOSE_MODE="$2"
CONFIG_FILE="$3"
FOLDER_PATH="$4"
MAX_DEPTH="$5"
CHECK_MODIFIED_FILES="$6"
BASE_BRANCH="$7"
if [ -z "$8" ]; then
   FILE_EXTENSION=".md"
else
   FILE_EXTENSION="$8"
fi
FILE_PATH="$9"
EXCLUDE_FOLDERS="${10:-}"
EXCLUDE_FILES="${11:-}"

if [ -f "$CONFIG_FILE" ]; then
   echo -e "${BLUE}Using markdown-link-check configuration file: ${YELLOW}$CONFIG_FILE${NC}"
else
   echo -e "${BLUE}Cannot find ${YELLOW}$CONFIG_FILE${NC}"
   echo -e "${YELLOW}NOTE: See https://github.com/tcort/markdown-link-check#config-file-format to know more about"
   echo -e "customizing markdown-link-check by using a configuration file.${NC}"
fi

echo -e "${BLUE}USE_QUIET_MODE: $USE_QUIET_MODE${NC}"
echo -e "${BLUE}USE_VERBOSE_MODE: $USE_VERBOSE_MODE${NC}"
echo -e "${BLUE}FOLDER_PATH: $FOLDER_PATH${NC}"
echo -e "${BLUE}MAX_DEPTH: $MAX_DEPTH${NC}"
echo -e "${BLUE}CHECK_MODIFIED_FILES: $CHECK_MODIFIED_FILES${NC}"
echo -e "${BLUE}FILE_EXTENSION: $FILE_EXTENSION${NC}"
echo -e "${BLUE}FILE_PATH: $FILE_PATH${NC}"
echo -e "${BLUE}EXCLUDE_FOLDERS: $EXCLUDE_FOLDERS${NC}"
echo -e "${BLUE}EXCLUDE_FILES: $EXCLUDE_FILES${NC}"

# Helper function to handle directory paths
handle_dirs () {
   IFS=',' read -r -a DIRLIST <<< "$FOLDER_PATH"

   for index in "${!DIRLIST[@]}"; do
      if [ ! -d "${DIRLIST[index]}" ]; then
         echo -e "${RED}ERROR [✖] Can't find the directory: ${YELLOW}${DIRLIST[index]}${NC}"
         exit 2
      fi
      # Add directory paths to the array
      FOLDERS+=("${DIRLIST[index]}")
   done
}

# Helper function to handle excluded directory paths
handle_exclude_dirs () {
   IFS=',' read -r -a EXCLUDE_DIRLIST <<< "$EXCLUDE_FOLDERS"

   for index in "${!EXCLUDE_DIRLIST[@]}"; do
      if [ ! -d "${EXCLUDE_DIRLIST[index]}" ]; then
         echo -e "${RED}ERROR [✖] Can't find the directory: ${YELLOW}${EXCLUDE_DIRLIST[index]}${NC}"
         exit 2
      fi
      # Add exclusion rules for directories to the array
      EXCLUDE_DIRS+=("-not -path '${EXCLUDE_DIRLIST[index]}'")
   done
}

# Helper function to handle file paths
handle_files () {
   IFS=',' read -r -a FILELIST <<< "$FILE_PATH"

   for index in "${!FILELIST[@]}"; do
      if [ ! -f "${FILELIST[index]}" ]; then
         echo -e "${RED}ERROR [✖] Can't find the file: ${YELLOW}${FILELIST[index]}${NC}"
         exit 2
      fi
      # Add file paths to the array
      COMMANDS+=("${FILELIST[index]}")
   done
}

# Helper function to handle excluded file paths
handle_exclude_files () {
   IFS=',' read -r -a EXCLUDE_FILELIST <<< "$EXCLUDE_FILES"

   for index in "${!EXCLUDE_FILELIST[@]}"; do
      if [ ! -f "${EXCLUDE_FILELIST[index]}" ]; then
         echo -e "${RED}ERROR [✖] Can't find the file: ${YELLOW}${EXCLUDE_FILELIST[index]}${NC}"
         exit 2
      fi
      # Add exclusion rules for files to the array
      EXCLUDE_FILES+=("-not -name '${EXCLUDE_FILELIST[index]}'")
   done
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

if [ -n "$CONFIG_FILE" ]; then
   COMMANDS+=("--config" "$CONFIG_FILE")
fi

if [ "$USE_QUIET_MODE" = "yes" ]; then
   COMMANDS+=("-q")
fi

if [ "$USE_VERBOSE_MODE" = "yes" ]; then
   COMMANDS+=("-v")
fi

if [ -n "$EXCLUDE_FOLDERS" ]; then
   handle_exclude_dirs
fi

if [ -n "$EXCLUDE_FILES" ]; then
   handle_exclude_files
fi

if [ "$CHECK_MODIFIED_FILES" = "yes" ]; then
   echo -e "${BLUE}BASE_BRANCH: $BASE_BRANCH${NC}"

   git config --global --add safe.directory '*'

   git fetch origin "$BASE_BRANCH" --depth=1 > /dev/null
   MASTER_HASH=$(git rev-parse origin/"$BASE_BRANCH")

   if [ -z "${FOLDERS[*]}" ]; then
      FOLDERS=(".")
   fi

   FOLDER_ARRAY=(${FOLDER_PATH//,/ })
   mapfile -t FILE_ARRAY < <(git diff --name-only --diff-filter=AM "$MASTER_HASH" -- "${FOLDER_ARRAY[@]}")

   for i in "${FILE_ARRAY[@]}"; do
      if [ "${i##*.}" == "${FILE_EXTENSION#.}" ]; then
         COMMANDS+=("$i")
         markdown-link-check "${COMMANDS[@]}" >> error.txt || true
         unset 'COMMANDS[${#COMMANDS[@]}-1]'
      fi
   done

   check_errors
else
   if [ "$MAX_DEPTH" -eq -1 ]; then
      MAX_DEPTH=""
   else
      MAX_DEPTH="-maxdepth $MAX_DEPTH"
   fi

   if [ -n "$FOLDER_PATH" ]; then
      handle_dirs

      # Find all files with the specified extension
      mapfile -t FILES < <(find "${FOLDERS[@]}" $MAX_DEPTH -type f -name "*$FILE_EXTENSION" "${EXCLUDE_DIRS[@]}" "${EXCLUDE_FILES[@]}")

      for i in "${FILES[@]}"; do
         COMMANDS+=("$i")
         markdown-link-check "${COMMANDS[@]}" >> error.txt || true
         unset 'COMMANDS[${#COMMANDS[@]}-1]'
      done

      check_errors
   else
      echo -e "${RED}ERROR [✖] No folder path provided.${NC}"
      exit 2
   fi
fi
