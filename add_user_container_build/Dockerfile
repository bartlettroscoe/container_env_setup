# This Dockerfile creates a derived container that adds a user and optionally
# opens up permissions from another directory in the container that needs to be
# accessed by this new user.
#
#   cd container_env_setup/
#   docker build [options] -f add_user_container_build/Dockerfile .
#
# See the README.md file in this directory for further instructions.
#

ARG BASE_IMAGE=does_not_exist_you_must_set_this_as_build_arg
FROM ${BASE_IMAGE}

# Set up the users
ARG NEW_USERNAME=
ARG HOST_UID=
ARG HOST_GID=
ARG OPEN_EXISTING_USER=
ARG RUN_AS_USER=${NEW_USERNAME}

# Fix permissions for an existing user so we can access files
COPY /open_perms_on_dir_if_users_different.sh /copied_from_host/
RUN chmod a+rX -R /copied_from_host/open_perms_on_dir_if_users_different.sh \
  && /copied_from_host/open_perms_on_dir_if_users_different.sh \
    /home/${OPEN_EXISTING_USER} ${OPEN_EXISTING_USER} ${NEW_USERNAME}
# NOTE: The above takes a long time, so we want to do this early and in its own
# RUN command so it caches early.

# Create a local user in the container matching the host user UID and GID
COPY /create_local_user.sh /copied_from_host/
RUN chmod a+rX -R /copied_from_host/create_local_user.sh \
  && /copied_from_host/create_local_user.sh ${NEW_USERNAME} "${HOST_UID}" "${HOST_GID}"

# Run as the requested user
USER ${RUN_AS_USER}
ENV USER=${RUN_AS_USER}
# NOTE: Docker does **not** automatically set the USER environment variable!
