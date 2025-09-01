#!/bin/bash -e
#
# Open read and execute permissions on a given home directory if it exists:
#
#   open_read_exec_perms_on_dir.sh <base-dir>
#

base_dir=$1

if [[ -d "${base_dir}" ]]; then
  echo "Opening read and execute permissions on directory: ${base_dir}"
  chmod -R a+rX "${base_dir}"
else
  echo "Directory does not exist: ${base_dir}"
fi
