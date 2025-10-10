# Build derived container that adds a user and related stuff

To build a derived container that adds a user to the container that matches the
UID and GID of the host user, and starts the container as that new user, first
CD to the base repo `container_env_setup` as:

```bash
cd container_env_setup/
```

then build a derived container as:

```bash
export BASE_IMAGE=trilinos-clang-19.1.6-openmpi-4.1.6:latest \
&& export NEW_USERNAME=${USER} \
&& export HOST_UID=$(id -u) \
&& export HOST_GID=$(id -g) \
&& export OPEN_EXISTING_USER= \
&& export DERIVED_IMAGE=trilinos-clang-19.1.6-openmpi-4.1.6-${NEW_USERNAME}:latest \
&& docker build \
  -t ${DERIVED_IMAGE} \
  --build-arg BASE_IMAGE=${BASE_IMAGE} \
  --build-arg NEW_USERNAME=${NEW_USERNAME} \
  --build-arg HOST_UID=${HOST_UID} \
  --build-arg HOST_GID=${HOST_GID} \
  --build-arg OPEN_EXISTING_USER=${OPEN_EXISTING_USER} \
  -f add_user_container_build/Dockerfile .
```

NOTE: If there is already a user in the base image `BASE_IMAGE` that matches the
UID and GID of the host user `${USER}`, then use that username for
`NEW_USERNAME` above and set `OPEN_EXISTING_USER=` if that is the same user. In
this case, the only effect will be to set teh default user as `${NEW_USERNAME}`.

NOTE: For Trilinos container there is a user `runner` that has UID:GID =
1000:1000.   And on WSL systems, you user is likely also UID:GID = 1000:000.  In
this case, you would set:

```bash
export NEW_USERNAME=${USER}
```

If you do need to open up the existing user directory `/home/runner`, also add set:

```bash
export OPEN_EXISTING_USER=runner
```

But newer Trilinos containers should have the `/home/runner` directory already
opened up.




