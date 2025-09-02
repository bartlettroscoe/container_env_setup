#!/bin/bash -e
#
# Open the same read, write, execute permissions as the owning owner for all for
# a given directory <basedir>/<subdir> if <subdir> is non-empty and
# <basedir>/<subdir> exists:
#
#   open_perms_on_dir.sh <basedir> <subdir>
#

basedir=$1
subdir=$2

if [[ "${subdir}" != "" ]] ; then
  path_to_open_up="${basedir}/${subdir}"
  if [[ -d "${path_to_open_up}" ]]; then
    echo "Opening read, write and execute permissions on directory: ${path_to_open_up}"
    chmod o+rwx,g+rwx ${path_to_open_up}
    find ${path_to_open_up} -type f -perm /u+r -exec chmod o+r,g+r {} +
    find ${path_to_open_up} -type f -perm /u+w -exec chmod o+w,g+w {} +
    find ${path_to_open_up} -type f -perm /u+x -exec chmod o+x,g+x {} +
    find ${path_to_open_up} -type d -perm /u+r -exec chmod o+r,g+r {} +
    find ${path_to_open_up} -type d -perm /u+w -exec chmod o+w,g+w {} +
    find ${path_to_open_up} -type d -perm /u+x -exec chmod o+x,g+x {} +
  else
    echo "Directory does not exist: ${path_to_open_up}"
  fi
else
  echo "Passed in subdir is empty!"
fi
