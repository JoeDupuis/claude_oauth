#!/bin/bash

# Set up rbenv environment
export PATH="/opt/rbenv/bin:$PATH"
export RBENV_ROOT="/opt/rbenv"
eval "$(rbenv init -)"

# Check if the first argument matches one of our scripts
case "$1" in
    "login_start"|"login_finish"|"refresh_token")
        # Execute the script directly (they have shebangs)
        script="/usr/local/bin/$1"
        shift  # Remove the script name from arguments
        exec "$script" "$@"
        ;;
    *)
        # Default: execute claude with all arguments
        exec claude "$@"
        ;;
esac