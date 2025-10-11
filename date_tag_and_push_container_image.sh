#!/bin/bash
#
# Add a date tag and optionally add a remote tag and push an image:
#
#   date_tag_and_push_container_image <image-name>:<image-tag> \
#     [<remote-prefix> [<push-prefix>]]
#
# Creates the tag:
#    <image-name>:$(date +%Y-%m-%d)
#
# If <remote-prefix> != "", then the following remote prefixed tags are created:
#   <remote-prefix>/<image-name>:<image-tag>
#   <remote-prefix>/<image-name>:<date-tag>
#
# If <push-prefix> == "push", then the remote-prefixed tags are pushed.
#

# Input command-line args
image_and_tag=$1; shift
remote_prefix=${1:""}; shift
push_prefix=${1:""}; shift

# Dry run?
if [[ "${BUILD_CONTAINER_DRY_RUN}" == "1" ]] ; then
  COMMAND_ECHO_PREFIX=echo
else
  COMMAND_ECHO_PREFIX=
fi

# Image name and tags
image_name=${image_and_tag%%:*}
#echo "image_name = $image_name"
tag=${image_and_tag#*:}
#echo "image_tag = $image_tag"
date_tag=$(date +%Y-%m-%d)
image_and_date_tag=${image_name}:${date_tag}

echo "Tagging ${image_and_date_tag}"
${COMMAND_ECHO_PREFIX} docker tag ${image_and_tag} ${image_and_date_tag}

if [[ "${remote_prefix}" != "" ]] ; then
  remote_prefix_image_name=${remote_prefix}/${image_name}
  echo "Tagging ${remote_prefix_image_name}:latest"
  ${COMMAND_ECHO_PREFIX} docker tag ${DERIVED_IMAGE} ${remote_prefix_image_name}:latest
  echo "Tagging ${remote_prefix_image_name}:${date_tag}"
  ${COMMAND_ECHO_PREFIX} docker tag ${DERIVED_IMAGE} ${remote_prefix_image_name}:${date_tag}
  if [[ "${push_prefix}" == "push" ]] ; then
    echo "Pushing ${remote_prefix_image_name}:latest"
    ${COMMAND_ECHO_PREFIX} docker push ${remote_prefix_image_name}:latest
    echo "Pushing ${remote_prefix_image_name}:${date_tag}"
    ${COMMAND_ECHO_PREFIX} docker push ${remote_prefix_image_name}:${date_tag}
  fi
fi
