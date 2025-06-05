#!/bin/bash
#
# Set up your env from what is mounted in /mounted/personal_cygwin_laptop_home
#
# Just run:
#
#   $ cd ~   # Takes you to /home/root
#   $ /mounted/personal_cygwin_laptop_home/rab_container_tools/set_up_home_dir_env.sh

SCRIPT_BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "{SCRIPT_BASE_DIR}" == "${PWD}" ]] ; then
  echo "ERROR: Can't run form this dir!  Run from home dir in container (e.g. /home/root)!"
  exit 1
fi

${SCRIPT_BASE_DIR}/../symlink_files.sh
rm .gitconfig
cp ${SCRIPT_BASE_DIR}/../.gitconfig .gitconfig
