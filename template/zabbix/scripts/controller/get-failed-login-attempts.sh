#!/usr/bin/bash
# ---------------------------------------------------------------------------
# get-failed-login-attempts.sh - Retrieves the quantity of failed login attempts since 9am the previous day.

# Copyright 2020,  Andrew Provis


#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
# 
# Copyright (C) 2004 Sam Hocevar <sam@hocevar.net>
#
# Everyone is permitted to copy and distribute verbatim or modified
# copies of this license document, and changing it is allowed as long
# as the name is changed.
#  
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
# 
#  0. You just DO WHAT THE FUCK YOU WANT TO.


# Usage: get-failed-login-attempts.sh [-h|--help]

# Revision history:
# 2020-12-16 - Ver. 0.1 - Initial creation.
# ---------------------------------------------------------------------------

PROGNAME=${0##*/}
VERSION="0.1"

HOST_OR_GROUP="-w"

clean_up() { # Perform pre-exit housekeeping
  return
}

error_exit() {
  echo -e "${PROGNAME}: ${1:-"Unknown Error"}" >&2
  clean_up
  exit 1
}

graceful_exit() {
  clean_up
  exit
}

signal_exit() { # Handle trapped signals
  case $1 in
    INT)
      error_exit "Program interrupted by user" ;;
    TERM)
      echo -e "\n$PROGNAME: Program terminated" >&2
      graceful_exit ;;
    *)
      error_exit "$PROGNAME: Terminating on unknown signal" ;;
  esac
}

usage() {
  echo -e "Usage: $PROGNAME [-h|--help]"
}

help_message() {
  cat <<- _EOF_
  $PROGNAME ver. $VERSION
  Retrieves the quantity of failed login attempts since 9am the previous day.

  $(usage)

  Options:
  -h, --help  Display this help message and exit.

_EOF_
  return
}

# Trap signals
trap "signal_exit TERM" TERM HUP
trap "signal_exit INT"  INT



# Parse command-line
while [[ -n $1 ]]; do
  case $1 in
    -h | --help)
      help_message; graceful_exit ;;
    -* | --*)
      usage
      error_exit "Unknown option $1" ;;
    *)
      HOSTS=$1 ;;
  esac
  shift
done

# Main logic

sudo awk -v d1="$(date --date="09:00 yesterday" "+%b %_d %H:%M:%S")" -v d2="$(date "+%b %_d %H:%M:%S")" '$0 > d1 && $0 < d2 || $0 ~ d2' /var/log/secure | grep -c "Failed password";

graceful_exit
