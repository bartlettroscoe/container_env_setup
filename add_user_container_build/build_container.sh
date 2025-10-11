#!/bin/bash
#
# Create a derived container adding <new_username> that matches UID:GID of host
# user:
#
#   <this-dir>/add_user_container_build/build_container.sh \
#     <base-image-name>:<base-image-tag> <new-username>
#
# To only do a dry-run and see what commands would be called, set the env var:
#
#   env BUILD_CONTAINER_DRY_RUN=1 ./build_container.sh [args]
#

# Input command-line args
base_image_and_tag=$1; shift
new_username=$1; shift

SCRIPT_BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -L)"
cd $(realpath "${SCRIPT_BASE_DIR}/..")
echo ${PWD}

# Dry run?
if [[ "${BUILD_CONTAINER_DRY_RUN}" == "1" ]] ; then
  COMMAND_ECHO_PREFIX=echo
else
  COMMAND_ECHO_PREFIX=
fi

base_image_name=${base_image_and_tag%%:*}
#echo "base_image_name = $base_image_name"
derived_image_name=${base_image_name}-${new_username}
#echo "derived_image_name = $derived_image_name"
date_tag=$(date +%Y-%m-%d)
derived_image_and_tag=${derived_image_name}:latest
derived_image_and_date_tag=${derived_image_name}:${date_tag}

export BASE_IMAGE=${base_image_and_tag} \
&& export NEW_USERNAME=${new_username} \
&& export HOST_UID=$(id -u) \
&& export HOST_GID=$(id -g) \
&& export OPEN_EXISTING_USER= \
&& export DERIVED_IMAGE=${derived_image_and_tag} \
&& echo "Building derived image: ${DERIVED_IMAGE}" \
&& ${COMMAND_ECHO_PREFIX} docker build \
  -t ${DERIVED_IMAGE} \
  --build-arg BASE_IMAGE=${BASE_IMAGE} \
  --build-arg NEW_USERNAME=${NEW_USERNAME} \
  --build-arg HOST_UID=${HOST_UID} \
  --build-arg HOST_GID=${HOST_GID} \
  --build-arg OPEN_EXISTING_USER=${OPEN_EXISTING_USER} \
  -f add_user_container_build/Dockerfile .

echo "Tagging ${derived_image_and_date_tag}"
${COMMAND_ECHO_PREFIX} docker tag ${DERIVED_IMAGE} ${derived_image_and_date_tag}
echo "Done building and tagging: ${derived_image_name}"
