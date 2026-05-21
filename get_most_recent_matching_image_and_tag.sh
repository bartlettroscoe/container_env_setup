#!/bin/bash
#
# Get the most recent <full-image-name>:<tag> matching a given image name
# pattern, taking into account possible prefixes that are not included in the
# image name pattern
#
#   ./get_most_recent_matching_image_and_tag.sh <image-and-tag-regex>
#
# For example:
#
#   ./get_most_recent_matching_image_and_tag.sh
#   "trilinos-clang-19.1.6-openmpi-4.1.6:latest"
#
# will return <name>:<tag> like:
#
#   trilinos-clang-19.1.6-openmpi-4.1.6:latest
#
# and:
#
#   bartlettroscoe/trilinos-clang-19.1.6-openmpi-4.1.6:latest
#
# but not:
#
#   codex-trilinos-clang-19.1.6-openmpi-4.1.6-rabartl:latest
#
# But the input:
#
#   ./get_most_recent_matching_image_and_tag.sh "trilinos-clang*:latest"
#
# would match either of:
#
#   trilinos-clang-19.1.6-openmpi-4.1.6-rabartl:latest
#   bartlettroscoe/trilinos-clang-19.1.6-openmpi-4.1.6:latest
#
# (which ever is the latest).
#

image_and_tag_regex=$1; shift
#echo "image_and_tag_regex = $image_and_tag_regex"

SCRIPT_BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -L)"
source ${SCRIPT_BASE_DIR}/use_docker_or_podman.sh

${docker_images} --format "{{.Repository}}:{{.Tag}}" \
  | grep -E "(^|/)${image_and_tag_regex}" | head -n 1
