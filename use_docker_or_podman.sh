# Source this script to use docker or podman

# Use podman or docker
podman_exec=$(which podman)
if [[ "${podman_exec}" != "" ]] ; then
  docker_images="${podman_exec} images"
  docker_inspect="${podman_exec} inspect"
  docker_tag="${podman_exec} tag"
  docker_push="${podman_exec} push --format oci"
else
  docker_images="docker images"
  docker_inspect="docker inspect"
  docker_tag="docker tag"
  docker_push="docker push"
fi

# NOTE: Above, we push with `podman push --format oci` in case image was built
# with `podman build --format docker`.
#
# By having these wrappers, we can tweak what these things do with podman.
