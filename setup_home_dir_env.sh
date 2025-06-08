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

echo "Moving .bash_profile to .bash_profile.orig so we can symlink ours"
if [[ -f .bash_profile ]] ; then
  mv .bash_profile .bash_profile.orig
fi

${SCRIPT_BASE_DIR}/../symlink-files.sh

echo "Creating copy of .gitdist so edits do not affect the host machine"
rm .gitconfig
cp ${SCRIPT_BASE_DIR}/../.gitconfig .gitconfig
