#!/bin/bash -e
#
# Open the same read, write, execute permissions as the owning owner for all for
# a given directory <path_to_open_up> if <existing_user> != <new_user>
#
#   open_perms_on_dir_if_users_different.sh <path_to_open_up> <existing_user>
#   <new_user>
#
# If <new_user> == root, then this is skipped as well because the root user can
# access everything already.   Also, if either <existing_user> or <new_user> are
# empty, this is skipped.
#
# Note that <new_user> does not need to actaully exist.  It just needs to be
# different than <existing_user> to trigger oppening the permsision.
#

path_to_open_up=$1
existing_user=$2
new_user=$3

echo "Opening permsisions for '${path_to_open_up}' with existing_user='${existing_user}', new_user='${new_user}'"

if [[ "${new_user}" == "root" ]] ; then
  echo "New user = '${new_user}', skipping!"
elif [[ "${new_user}" == "" ]] ; then
  echo "New user = '${new_user}', skipping!"
elif [[ "${existing_user}" == "" ]] ; then
  echo "Existing user = '${existing_user}', skipping!"
elif [[ ! -d ${path_to_open_up} ]] ; then
  echo "Directory does not exist ${path_to_open_up}, skipping!"
elif [[ "${existing_user}" == "${new_user}" ]] ; then
  echo "Existing user '${existing_user}' == New user '${new_user}', skipping!"
else
  echo "Opening read, write and execute permissions on directory: ${path_to_open_up}"
  chmod o+rwx,g+rwx ${path_to_open_up}
  find ${path_to_open_up} -type f -perm /u+r -exec chmod o+r,g+r {} +
  find ${path_to_open_up} -type f -perm /u+w -exec chmod o+w,g+w {} +
  find ${path_to_open_up} -type f -perm /u+x -exec chmod o+x,g+x {} +
  find ${path_to_open_up} -type d -perm /u+r -exec chmod o+r,g+r {} +
  find ${path_to_open_up} -type d -perm /u+w -exec chmod o+w,g+w {} +
  find ${path_to_open_up} -type d -perm /u+x -exec chmod o+x,g+x {} +
fi
