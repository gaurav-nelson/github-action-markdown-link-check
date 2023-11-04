#!/usr/bin/env bash

set -eu

# Declare some variables for the color codes
NC='\033[0m' # No Color
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'

# Declare some variables for the options and arguments
USE_QUIET_MODE="$1"
USE_VERBOSE_MODE="$2"
CONFIG_FILE="$3"
FOLDER_PATH="$4"
MAX_DEPTH="$5"
CHECK_MODIFIED_FILES="$6"
BASE_BRANCH="$7"
FILE_EXTENSION="$8"
FILE_PATH="$9"

# Declare some variables for the default values
DEFAULT_FILE_EXTENSION=".md"
DEFAULT_FOLDER_PATH="."
DEFAULT_MAX_DEPTH="-1"
DEFAULT_BASE_BRANCH="master"
DEFAULT_ERROR_FILE="error.txt"
DEFAULT_ERROR_CODE="113"

# Declare some arrays to store the directories and files to check
declare -a COMMAND_DIRS COMMAND_FILES

# Install markdown-link-check globally
npm i -g markdown-link-check@3.11.1

# Show the global npm packages installed
echo "::group::Debug information"
npm -g list --depth=1
echo "::endgroup::"

# A function to print a message with a color
print_message () {
  local COLOR="$1" # Get the first argument as the color
  local MESSAGE="$2" # Get the second argument as the message
  echo -e "${COLOR}${MESSAGE}${NC}" # Print the message with the color and no color
}

# A function to run the markdown-link-check command with the options
run_markdown_link_check () {
  local FILE="$1" # Get the first argument as the file name
  local OPTIONS=() # Declare an array to store the options
  if [ -f "$CONFIG_FILE" ]; then # Check if the config file exists
    OPTIONS+=('--config' "${CONFIG_FILE}") # Add the --config option to the options array
  fi
  if [ "$USE_QUIET_MODE" = "yes" ]; then # Check if the quiet mode is enabled
    OPTIONS+=('-q') # Add the -q option to the options array
  fi
  if [ "$USE_VERBOSE_MODE" = "yes" ]; then # Check if the verbose mode is enabled
    OPTIONS+=('-v') # Add the -v option to the options array
  fi
  markdown-link-check "${OPTIONS[@]}" "$FILE" &>> "$DEFAULT_ERROR_FILE" || true # Run the markdown-link-check command with the options and the file name, and append the output to the error file, ignore the exit code
}

# A function to parse and validate the arguments
parse_arguments () {
  # Set the default values for the arguments
  if [ -z "$FILE_EXTENSION" ]; then
    FILE_EXTENSION="$DEFAULT_FILE_EXTENSION"
  fi
  if [ -z "$FOLDER_PATH" ]; then
    FOLDER_PATH="$DEFAULT_FOLDER_PATH"
  fi
  if [ -z "$MAX_DEPTH" ]; then
    MAX_DEPTH="$DEFAULT_MAX_DEPTH"
  fi
  if [ -z "$BASE_BRANCH" ]; then
    BASE_BRANCH="$DEFAULT_BASE_BRANCH"
  fi
  # Print the arguments
  print_message "$BLUE" "USE_QUIET_MODE: $USE_QUIET_MODE"
  print_message "$BLUE" "USE_VERBOSE_MODE: $USE_VERBOSE_MODE"
  print_message "$BLUE" "CONFIG_FILE: $CONFIG_FILE"
  print_message "$BLUE" "FOLDER_PATH: $FOLDER_PATH"
  print_message "$BLUE" "MAX_DEPTH: $MAX_DEPTH"
  print_message "$BLUE" "CHECK_MODIFIED_FILES: $CHECK_MODIFIED_FILES"
  print_message "$BLUE" "FILE_EXTENSION: $FILE_EXTENSION"
  print_message "$BLUE" "FILE_PATH: $FILE_PATH"
  # Check if the config file exists
  if [ -f "$CONFIG_FILE" ]; then
    print_message "$BLUE" "Using markdown-link-check configuration file: $CONFIG_FILE"
  else
    print_message "$BLUE" "Cannot find $CONFIG_FILE"
    print_message "$YELLOW" "NOTE: See https://github.com/tcort/markdown-link-check#config-file-format to know more about customizing markdown-link-check by using a configuration file."
  fi
}

# A function to handle the directories
handle_dirs () {
  IFS=', ' read -r -a DIRLIST <<< "$FOLDER_PATH" # Split the folder path by comma and store it in an array
  for index in "${!DIRLIST[@]}"
  do
    if [ ! -d "${DIRLIST[index]}" ]; then # Check if the directory exists
      print_message "$RED" "ERROR [✖] Can't find the directory: ${DIRLIST[index]}"
      exit 2 # Exit with error code 2
    fi
    COMMAND_DIRS+=("${DIRLIST[index]}") # Add the directory to the command dirs array
  done
}

# A function to handle the files
handle_files () {
  IFS=', ' read -r -a FILELIST <<< "$FILE_PATH" # Split the file path by comma and store it in an array
  for index in "${!FILELIST[@]}"
  do
    if [ ! -f "${FILELIST[index]}" ]; then # Check if the file exists
      print_message "$RED" "ERROR [✖] Can't find the file: ${FILELIST[index]}"
      exit 2 # Exit with error code 2
    fi
    if [ "$index" == 0 ]; then
      COMMAND_FILES+=("-wholename ${FILELIST[index]}") # Add the file name with -wholename option to the command files array
    else
      COMMAND_FILES+=("-o -wholename ${FILELIST[index]}") # Add the file name with -o and -wholename options to the command files array
    fi
  done
}

# A function to check and delete the error file
check_error_file () {
  if [ -e "$DEFAULT_ERROR_FILE" ] ; then # Check if the error file exists
    if grep -q "ERROR:" "$DEFAULT_ERROR_FILE"; then # Check if the error file contains any ERROR: lines
      print_message "$YELLOW" "=========================> MARKDOWN LINK CHECK <========================="
      cat "$DEFAULT_ERROR_FILE" # Print the error file
      printf "\n"
      print_message "$YELLOW" "========================================================================="
      rm "$DEFAULT_ERROR_FILE" # Delete the error file
      exit "$DEFAULT_ERROR_CODE" # Exit with the default error code
    else
      print_message "$YELLOW" "=========================> MARKDOWN LINK CHECK <========================="
      printf "\n"
      print_message "$GREEN" "[✔] All links are good!"
      printf "\n"
      print_message "$YELLOW" "========================================================================="
      rm "$DEFAULT_ERROR_FILE" # Delete the error file
    fi
  else
    print_message "$GREEN" "All good!"
  fi
}

# Parse and validate the arguments
parse_arguments

# Handle the directories
handle_dirs

# Handle the files
handle_files

if [ "$CHECK_MODIFIED_FILES" = "yes" ]; then # Check if the check modified files option is enabled

  print_message "$BLUE" "BASE_BRANCH: $BASE_BRANCH" # Print the base branch name

  git config --global --add safe.directory '*' # Add a global git config to allow any directory name

  git fetch origin "${BASE_BRANCH}" --depth=1 > /dev/null # Fetch the base branch from origin with depth 1 and discard the output
  MASTER_HASH=$(git rev-parse origin/"${BASE_BRANCH}") # Get the hash of the base branch

  mapfile -t FILE_ARRAY < <( git diff --name-only --diff-filter=AM "$MASTER_HASH" -- "${COMMAND_DIRS[@]}") # Get the modified files from the git diff and store them in an array

  # Use xargs to run the markdown-link-check command on multiple files at once
  printf '%s\n' "${FILE_ARRAY[@]}" | xargs -P 10 -I {} bash -c 'run_markdown_link_check "$@"' _ {} "$FILE_EXTENSION"

  # Check and delete the error file
  check_error_file

else

  # Use xargs to run the markdown-link-check command on multiple files at once
  find "${COMMAND_DIRS[@]}" -iname "*${FILE_EXTENSION}" -not -path './node_modules/*' -maxdepth "${MAX_DEPTH}" -print0 | xargs -0 -P 10 -I {} bash -c 'run_markdown_link_check "$1"' _ {}

  # Check and delete the error file
  check_error_file

fi
