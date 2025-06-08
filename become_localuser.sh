#!/bin/bash -e
#
# Become the local user and get into their shell:
#
#   become_localuser.sh [-p]
#
# If called with the argument '-p', it will source .bash_profile.  Otherwise,
# .bashrc will be sourced.
#
# This script should only be called after the script
# setup_container_as_local_uid_gid.sh has been called.
#

use_bash_profile_arg=$1  # Optional

if [[ "${LOCAL_UID}" == "" ]] ; then
  echo "Error: LOCAL_UID is not set!  Env not set up correctly!"
  exit 1
fi

local_username=$(getent passwd "${LOCAL_UID}" | cut -d: -f1)

if [[ "${use_bash_profile_arg}" == "-p" ]] ; then
  source_file="/home/${local_username}/.bash_profile"
elif [[ "${use_bash_profile_arg}" != "" ]] ; then
  echo "Error: Invalid argument '${use_bash_profile_arg}'!" \
    " Use '-p' to source .bash_profile or no argument to source .bashrc."
  exit 1
else
  source_file="/home/${local_username}/.bashrc"
fi

exec su - "${local_username}" -c "bash --rcfile ${source_file}"
