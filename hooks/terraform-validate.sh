#!/usr/bin/env bash

set -e

# OSX GUI apps do not pick up environment variables the same way as Terminal apps and there are no easy solutions,
# especially as Apple changes the GUI app behavior every release (see https://stackoverflow.com/q/135688/483528). As a
# workaround to allow GitHub Desktop to work, add this (hopefully harmless) setting here.
export PATH=$PATH:/usr/local/bin

# Disable output not usually helpful when running in automation (such as guidance to run plan after init)
export TF_IN_AUTOMATION=1

parse_arguments() {
  while (($# > 0)); do
    # Check for --use-cache
    if [[ "$@" == *"--enable-cache"* ]]; then
      if [[ -z $AGENT_TEMPDIRECTORY ]]; then
        local CACHE_DIR="/tmp"
      else
        local CACHE_DIR=$AGENT_TEMPDIRECTORY
      fi
      export TF_PLUGIN_CACHE_DIR=$CACHE_DIR
    fi
}

# Store and return last failure from validate so this can validate every directory passed before exiting
VALIDATE_ERROR=0

for dir in $(echo "$@" | xargs -n1 dirname | sort -u | uniq); do
  echo "--> Running 'terraform validate' in directory '$dir'"
  pushd "$dir" >/dev/null
  terraform init -backend=false || VALIDATE_ERROR=$?
  terraform validate || VALIDATE_ERROR=$?
  popd >/dev/null
done

exit ${VALIDATE_ERROR}
