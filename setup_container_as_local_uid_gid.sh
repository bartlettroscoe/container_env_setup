#!/bin/bash -e
#
# This script sets up the container to run as a user with the same UID and GID
# as the host user.  That way, that user in the container can create and write
# files and directories in the host user's mounted directory and those files and
# directories will be owned by the host user, not root, on the host hose
# machine.
#
# Once the container is first started up, this script must be run once.
#
#   setup_container_as_local_uid_gid.sh
#
# This reads the environment variables LOCAL_USERNAME, LOCAL_UID, and LOCAL_GID
# (i.e. put into /root/.bashrc by VSCode devcontainer.json)  
#
# If an existing group with gid=${LOCAL_GROUP} is found, it will use that group
# and no new group will be created.
#
# If an existing user with uid=${LOCAL_USER} is found, it will use that user and
# no new user will be created.
#
# After this script is run, it symlinks the script /root/become_localuser.sh.
# That script is then run to become the local user and get into their shell.
#

SCRIPT_BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

requested_username=${LOCAL_USERNAME}
local_userid=${LOCAL_UID}
local_groupid=${LOCAL_GID}

# Determine the actual username to use
if getent passwd "$local_userid" > /dev/null; then
  local_username=$(getent passwd "$local_userid" | cut -d: -f1)
  echo "User with UID $local_userid already exists as '$local_username'"
else
  local_username="$requested_username"
fi

echo "Starting Dev Container setup for user: $local_username ($local_userid:$local_groupid)"

# Create the group if it does not exist
if ! getent group "$local_groupid" > /dev/null; then
  echo "Creating group $local_groupid"
  groupadd -g "$local_groupid" "$requested_username"
else
  echo "Group $local_groupid already exists"
fi

# Check if user exists by UID
if ! getent passwd "$local_userid" > /dev/null; then
  echo "Creating user $local_username with UID $local_userid and GID $local_groupid"
  useradd -m -u "$local_userid" -g "$local_groupid" -s /bin/bash "$local_username"
else
  echo "Using existing user $local_username with UID $local_userid"
  
  # Check if the existing user is in the target group
  if ! groups "$local_username" | grep -q "\b$local_groupid\b"; then
    echo "Adding existing user $local_username to group $local_groupid"
    usermod -aG "$local_groupid" "$local_username"
  else
    echo "User $local_username is already in group $local_groupid"
  fi
fi

# Add the user to the sudo group
if ! groups "$local_username" | grep -q '\bsudo\b'; then
  echo "Adding user $local_username to the sudo group"
  usermod -aG sudo "$local_username" || echo "There is no sudo group, skipping"
else
  echo "User $local_username is already in the sudo group"
fi

# Ensure the user has a home directory
if [ ! -d "/home/$local_username" ]; then
  echo "Creating home directory for user $local_username"
  mkdir -p "/home/$local_username"
  chown "$local_userid":"$local_groupid" "/home/$local_username"
else
  echo "Home directory for user $local_username already exists"
fi

# Symlink mounted directories into users home directory
if [ -d "/mounted_from_host" ]; then
  for dir in /mounted_from_host/*; do
    if [ -d "$dir" ]; then
      echo "Symlinking directory $dir to /home/$local_username"
      ln -s "$dir" "/home/$local_username/$(basename "$dir")" || echo "Symlink for $(basename "$dir") already exists!"
    else
      echo "Skipping non-directory $dir"
    fi
  done
else
  echo "/mounted_from_host does not exist, skipping symlinking"
fi

echo "Symlinking ${HOME}/become_localuser.sh"
ln -sf "${SCRIPT_BASE_DIR}/become_localuser.sh" "${HOME}/become_localuser.sh"

echo "Dev Container setup complete for user: $local_username ($local_userid:$local_groupid)"

