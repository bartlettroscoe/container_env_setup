#!/bin/bash -e
#
# Set up a local user matching the input <requested_username>, <local_uid>, and
# <host_gid>:
#
#   create_local_user.sh <requested_username> <local_uid > <host_gid> [sudo]
#
# where this must run as root (or sudo).  If an existing user with <uid> exists,
# then that user will be created.
#
# If the last argument 'sudo' is set, the user will be added to the sudo group.
#
# This script will return to STDOUT the last line the user with the <local_uid>.
# This could be <requested_username> or an existing user that has <local_uid>.
#
# If <local_uid> or <local_gid> are empty, then the script will do nothing.
#

# Input args
requested_username=$1
local_uid=$2
local_gid=$3
sudo_arg=$4

if [[ "${local_uid}" == "" ]] || [[ "${local_gid}" == "" ]] ; then
  echo "local_uid='${local_uid}', local_uid='${local_uid}', skipping creation of '${requested_username}'"
  exit 0
fi

# Determine the actual username to use, in case user with UID already exists
if getent passwd "$local_uid" > /dev/null; then
  local_username=$(getent passwd "$local_uid" | cut -d: -f1)
  echo "User with UID $local_uid already exists as '$local_username'"
else
  local_username="$requested_username"
fi

echo "Set up local user: $local_username ($local_uid:$local_gid)"

# Create the group if it does not exist
if ! getent group "$local_gid" > /dev/null; then
  echo "Creating new group $requested_username with gid=$local_gid"
  groupadd -g "$local_gid" "$requested_username"
else
  echo "Group with GID=$local_gid already exists"
fi

# Create the user if it does not exist with the matching UID
if ! getent passwd "$local_uid" > /dev/null; then
  echo "Creating user $local_username with UID=$local_uid and GID=$local_gid"
  useradd -m -u "$local_uid" -g "$local_gid" -s /bin/bash "$local_username"
else
  echo "Using existing user $local_username with UID $local_uid"
  
  # Check if the existing user is in the target group with GID
  if ! groups "$local_username" | grep -q "\b$local_gid\b"; then
    echo "Adding existing user $local_username to group $local_gid"
    usermod -aG "$local_gid" "$local_username"
  else
    echo "User $local_username is already in group $local_gid"
  fi
fi

# Ensure the user has a home directory
if [[ ! -d "/home/$local_username" ]] ; then
  echo "Creating home directory for user $local_username"
  mkdir -p "/home/$local_username"
  chown "$local_uid":"$local_gid" "/home/$local_username"
else
  echo "Home directory for user $local_username already exists"
fi

# Add the user to the sudo group if asked
if [[ "${sudo_arg}" == "sudo" ]] ; then
  if ! groups "$local_username" | grep -q '\bsudo\b'; then
    echo "Adding user $local_username to the sudo group"
    usermod -aG sudo "$local_username" || echo "There is no sudo group, skipping"
  else
    echo "User $local_username is already in the sudo group"
  fi
fi

# Echo the user name used as the last line as promised
echo $local_username
