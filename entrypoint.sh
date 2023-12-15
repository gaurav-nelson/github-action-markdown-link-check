#!/usr/bin/env bash

set -eu

NC='\033[0m' # No Color
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'

# Install markdown-link-check globally
npm i -g markdown-link-check@3.11.1
echo "::group::Debug information"
npm -g list --depth=1
echo "::endgroup::"

declare -a FIND_CALL
declare -a COMMAND_DIRS COMMAND_FILES
declare -a COMMAND_FILES=()

USE_QUIET_MODE="$1"
USE_VERBOSE_MODE="$2"
CONFIG_FILE="$3"
FOLDER_PATH="$4"
MAX_DEPTH="$5"
CHECK_MODIFIED_FILES="$6"
BASE_BRANCH="$7"
FILE_EXTENSION="${8:-.md}"
FILE_PATH="$9"
CREATE_ISSUE="${10:-false}"
DEFAULT_ISSUE_TITLE="🔥 Dead {n} Links Found in Markdown Files"

if [ -f "$CONFIG_FILE" ]; then
   ISSUE_TITLE=$(jq -r '.issue_title' "$CONFIG_FILE")
   echo -e "${BLUE}Using markdown-link-check configuration file: ${YELLOW}$CONFIG_FILE${NC}"
else
   ISSUE_TITLE="$DEFAULT_ISSUE_TITLE"
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
echo -e "${BLUE}CREATE_ISSUE: $CREATE_ISSUE${NC}"

handle_dirs () {
   IFS=', ' read -r -a DIRLIST <<< "$FOLDER_PATH"

   for dir in "${DIRLIST[@]}"
   do
      if [ ! -d "$dir" ]; then
         echo -e "${RED}ERROR [✖] Can't find the directory: ${YELLOW}$dir${NC}"
         exit 2
      fi
      COMMAND_DIRS+=("$dir")
   done
   FOLDERS="${COMMAND_DIRS[*]}"
}

handle_files () {
   IFS=', ' read -r -a FILELIST <<< "$FILE_PATH"

   for file in "${FILELIST[@]}"
   do
      if [ ! -f "$file" ]; then
         echo -e "${RED}ERROR [✖] Can't find the file: ${YELLOW}$file${NC}"
         exit 2
      fi
      if [ "${#COMMAND_FILES[@]}" -eq 0 ]; then
         COMMAND_FILES+=("-wholename $file")
      else
         COMMAND_FILES+=("-o -wholename $file")
      fi
   done
   FILES="${COMMAND_FILES[*]}"
}

check_errors () {
   if [ -e error.txt ]; then
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
      FIND_CALL+=('--config' "$CONFIG_FILE")
   fi

   [ "$USE_QUIET_MODE" = "yes" ] && FIND_CALL+=('-q')
   [ "$USE_VERBOSE_MODE" = "yes" ] && FIND_CALL+=('-v')
}

check_additional_files () {
   if [ -n "$FILES" ]; then
      if [ "$MAX_DEPTH" -ne -1 ]; then
         FIND_CALL=("find" $FOLDERS "-type f" "(" $FILES ")" "-not -path './node_modules/*' -maxdepth $MAX_DEPTH -exec markdown-link-check {}")
      else
         FIND_CALL=("find" $FOLDERS "-type f" "(" $FILES ")" "-not -path './node_modules/*' -exec markdown-link-check {}")
      fi

      add_options

      FIND_CALL+=(";")

      set -x
      "${FIND_CALL[@]}" &>> error.txt
      set +x
   fi
}

read_issue_body() {
    if [ -f "/.bed_links_body.md" ]; then
        cat "/.bed_links_body.md"
    else
        echo "The following dead links were found in Markdown files:"
    fi
}

# Create a function to check and create an issue
check_and_create_issue() {
    if [ "$CREATE_ISSUE" = "true" ]; then
        if [ -e error.txt ]; then
            if grep -q "ERROR:" error.txt; then
                echo -e "${YELLOW}=========================> MARKDOWN LINK CHECK <=========================${NC}"
                cat error.txt
                printf "\n"
                echo -e "${YELLOW}=========================================================================${NC}"
                
                # Create a new issue with the dead links
                DEAD_LINKS=$(grep -oP 'ERROR: \K[^ ]+' error.txt)
                ISSUE_TITLE="${ISSUE_TITLE//\{n\}/${#DEAD_LINKS}}"
                ISSUE_BODY="$(read_issue_body)\n\n$DEAD_LINKS\n\n"
                
                # Use GitHub API to create the issue
                GITHUB_API_URL="https://api.github.com/repos/${GITHUB_REPOSITORY}/issues"
                AUTH_HEADER="Authorization: token ${GITHUB_TOKEN}"
                ISSUE_DATA="{\"title\":\"$ISSUE_TITLE\",\"body\":\"$ISSUE_BODY\"}"
                
                curl -s -H "${AUTH_HEADER}" -d "${ISSUE_DATA}" "${GITHUB_API_URL}"

                printf "\n"
                echo -e "${RED}[✖] Dead links found! An issue has been created.${NC}"
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
    fi
}

if [ -z "$FILE_PATH" ]; then
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

   git fetch origin "$BASE_BRANCH" --depth=1 > /dev/null
   MASTER_HASH=$(git rev-parse origin/"$BASE_BRANCH")

   if [ -z "$FOLDERS" ]; then
      FOLDERS="."
   fi

   FIND_CALL=("markdown-link-check")

   add_options

   FOLDER_ARRAY=(${FOLDER_PATH//,/ })
   mapfile -t FILE_ARRAY < <(git diff --name-only --diff-filter=AM "$MASTER_HASH" -- "${FOLDER_ARRAY[@]}")

   for i in "${FILE_ARRAY[@]}"
   do
      if [ "${i##*.}" == "${FILE_EXTENSION#.}" ]; then
         FIND_CALL+=("$i")
         COMMAND="${FIND_CALL[*]}"
         $COMMAND &>> error.txt || true
         unset 'FIND_CALL[${#FIND_CALL[@]}-1]'
      fi
   done

   check_additional_files

   check_errors

   check_and_create_issue
else
   if [ "$MAX_DEPTH" -ne -1 ]; then
      FIND_CALL=("find" $FOLDERS "-name '*$FILE_EXTENSION'" "-not -path './node_modules/*' -maxdepth $MAX_DEPTH -exec markdown-link-check {}")
   else
      FIND_CALL=("find" $FOLDERS "-name '*$FILE_EXTENSION'" "-not -path './node_modules/*' -exec markdown-link-check {}")
   fi

   add_options

   FIND_CALL+=(";")

   set -x
   "${FIND_CALL[@]}" &>> error.txt
   set +x

   check_additional_files

   check_errors

   check_and_create_issue
fi
