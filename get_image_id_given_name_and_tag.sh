#!/bin/bash
#
# Get the container image ID given a container <image-name>:<image-tag>
#
#   ./get_image_id_given_name_and_tag.sh <image-name>:<image-tag>
#

image_and_tag_regex=$1; shift
#echo "image_and_tag_regex = $image_and_tag_regex"

SCRIPT_BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -L)"
source ${SCRIPT_BASE_DIR}/use_docker_or_podman.sh

${docker_inspect} --format='{{.Id}}' ${image_and_tag_regex}
