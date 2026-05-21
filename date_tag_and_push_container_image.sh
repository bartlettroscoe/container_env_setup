#!/bin/bash
#
# Add a date tag and optionally add a remote tag and push an image:
#
#   date_tag_and_push_container_image <image-name>:<image-tag> \
#     [<remote-prefix> [<push-prefix>]]
#
# Creates the tag:
#
#    <image-name>:<YYYY>-<MM>-<DD>
#
# if there is not already an exiting image with the same image ID with an
# exiting date tag.
#
# If <remote-prefix> != "", then the following remote prefixed tags are created:
#   <remote-prefix>/<image-name>:<image-tag>
#   <remote-prefix>/<image-name>:<date-tag>
#
# If <push-prefix> == "push", then the remote-prefixed tags are pushed.
#
# In addition, this will write a file that gives <image-name>:<image-tag> by
# setting the env var:
#
#    export WRITE_GENERATED_IMAGE_NAME_AND_TAG_TO_FILE=<file-path>
#
# On the completion of this script, the file at <file-path> will contain the
# most recent full image name and tag.
#
# NOTE: When doing a dry-run to see the commands that would be called, set:
#
#   export BUILD_CONTAINER_DRY_RUN=1
#

# Input command-line args
image_and_tag=$1; shift
#echo "image_and_tag = $image_and_tag"
remote_prefix=$1; shift
#echo "remote_prefix = $remote_prefix"
push_prefix=$1; shift
#echo "push_prefix = $push_prefix"

SCRIPT_BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -L)"
source ${SCRIPT_BASE_DIR}/use_docker_or_podman.sh

# Dry run?
if [[ "${BUILD_CONTAINER_DRY_RUN}" == "1" ]] ; then
  COMMAND_ECHO_PREFIX=echo

else
  COMMAND_ECHO_PREFIX=
fi

# Assert inputs image_name:image_tag has ":"
[[ "$image_and_tag" == *:* ]] || {
  echo "ERROR: image string has no ':' tag separator" >&2
  exit 1
}

# Image name, tag, and ID for input <image-name>:<image-tag>
image_base_name=$(${SCRIPT_BASE_DIR}/extract_image_basename_from_image_and_tag.sh ${image_and_tag})
#echo "image_base_name = $image_base_name"
image_tag=$(${SCRIPT_BASE_DIR}/extract_image_tag_from_image_and_tag.sh ${image_and_tag})
#echo "image_tag = $image_tag"
image_id=$(${SCRIPT_BASE_DIR}/get_image_id_given_name_and_tag.sh ${image_and_tag})
#echo "image_id = $image_id"

# Candidate image and today date tag
today_date_tag=$(date +%Y-%m-%d)
#echo "today_date_tag = $today_date_tag"

# Get the date tag of the most recent image with the same image base name
most_recent_image_name_and_date_tag=$(${SCRIPT_BASE_DIR}/get_most_recent_matching_image_and_tag.sh \
 "${image_base_name}:[0-9]{4}-[0-9]{2}-[0-9]{2}$")
#echo "most_recent_image_and_date_tag = $most_recent_image_name_and_date_tag"
most_recent_image_base_name_with_a_date_tag=$(${SCRIPT_BASE_DIR}/extract_image_basename_from_image_and_tag.sh \
  ${most_recent_image_name_and_date_tag})
#echo "most_recent_image_base_name_with_a_date_tag = $most_recent_image_base_name_with_a_date_tag"
most_recent_image_with_a_date_tag_date_tag=$(${SCRIPT_BASE_DIR}/extract_image_tag_from_image_and_tag.sh \
  ${most_recent_image_name_and_date_tag})
#echo "most_recent_image_with_a_date_tag_date_tag = $most_recent_image_with_a_date_tag_date_tag"
most_recent_image_with_a_date_tag_date_tagmost_recent_image_with_a_date_tag_id=$(${SCRIPT_BASE_DIR}/get_image_id_given_name_and_tag.sh \
  ${most_recent_image_name_and_date_tag})
#echo "most_recent_image_with_a_date_tag_date_tagmost_recent_image_with_a_date_tag_id = $most_recent_image_with_a_date_tag_date_tagmost_recent_image_with_a_date_tag_id"

# Put on the local date tag
if [[ "${image_base_name}" == "${most_recent_image_base_name_with_a_date_tag}" ]] \
    && [[ "${image_id}" == "${most_recent_image_with_a_date_tag_date_tagmost_recent_image_with_a_date_tag_id}" ]] \
    ; then
  echo "NOTE: Image '${image_and_tag}' with ID '${most_recent_image_with_a_date_tag_date_tagmost_recent_image_with_a_date_tag_id}' matches the ID previous image '${most_recent_image_base_name_with_a_date_tag}', so will use the previous date tag '${most_recent_image_with_a_date_tag_date_tag}'"
  date_tag=${most_recent_image_with_a_date_tag_date_tag}
  apply_date_tag=0
else
  date_tag=${today_date_tag}
  apply_date_tag=1
fi
#echo "date_tag = $date_tag"

# Tag the image with today's date tag if image ID has been updated
if [[ "${apply_date_tag}" == "1" ]] ; then
  image_and_date_tag=${image_base_name}:${date_tag}
  #echo "image_and_date_tag = $image_and_date_tag"
  echo "Tagging ${image_and_date_tag}"
  ${COMMAND_ECHO_PREFIX} ${docker_tag} ${image_and_tag} ${image_and_date_tag}
fi

# Write the full image name and tag to the file
if [[ "${WRITE_GENERATED_IMAGE_NAME_AND_TAG_TO_FILE}" != "" ]] ; then
  full_image_and_tag=$(${SCRIPT_BASE_DIR}/get_most_recent_matching_image_and_tag.sh \
    "${image_base_name}:${image_tag}$")
  echo "Writing '${full_image_and_tag}' to file WRITE_GENERATED_IMAGE_NAME_AND_TAG_TO_FILE='${WRITE_GENERATED_IMAGE_NAME_AND_TAG_TO_FILE}'"
  echo -n "${full_image_and_tag}" > ${WRITE_GENERATED_IMAGE_NAME_AND_TAG_TO_FILE}
fi

# Put on matching remote tags
if [[ "${remote_prefix}" != "" ]] ; then
  remote_prefix_image_name=${remote_prefix}/${image_base_name}
  echo "Tagging ${remote_prefix_image_name}:${image_tag}"
  ${COMMAND_ECHO_PREFIX} ${docker_tag} ${image_and_tag} ${remote_prefix_image_name}:${image_tag}
  echo "Tagging ${remote_prefix_image_name}:${date_tag}"
  ${COMMAND_ECHO_PREFIX} ${docker_tag} ${image_and_tag} ${remote_prefix_image_name}:${date_tag}
  if [[ "${push_prefix}" == "push" ]] ; then
    echo "Pushing ${remote_prefix_image_name}:${image_tag}"
    ${COMMAND_ECHO_PREFIX} ${docker_push} ${remote_prefix_image_name}:${image_tag}
    echo "Pushing ${remote_prefix_image_name}:${date_tag}"
    ${COMMAND_ECHO_PREFIX} ${docker_push} ${remote_prefix_image_name}:${date_tag}
  fi
fi
