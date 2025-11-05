# Build derived container that adds a user matching the host user UID and GID

To build a derived container that adds a user to the container that matches the
UID and GID of the host user, and starts the container as that new user, first
CD to the base repo `container_env_setup` as:

```bash
cd container_env_setup/
```

then do the `docker build` (for example with the base image
`trilinos-clang-19.1.6-openmpi-4.1.6:latest`) as:

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
UID and GID of the host user `${USER}` (e.g., `runner`), then use that username
for `NEW_USERNAME` above and set `OPEN_EXISTING_USER=` if that is the same user.
In this case, the only effect will be to set the default user as
`${NEW_USERNAME}`.

Or, one can call the script [`build_container.sh`](./build_container.sh) from
any base directory as:

```bash
<this-dir>/add_user_container_build/build_container.sh \
  codex-mull-trilinos-clang-19.1.6-openmpi-4.1.6:latest \
  ${USER}
```

which creates the image
`codex-mull-trilinos-clang-19.1.6-openmpi-4.1.6-${USER}:latest` and also adds
the date tag `<YYYY>-<MM>-<DD>` for the generated image.

NOTE: If there is already a user `<existing-user>` in the base image that
matches the UID and GID of the host user `${USER}`, then use that user name
`<existing-user>` instead of `${USER}` above.  In this case, the only effect
will be to set the default user as `<existing-user>`.

NOTE: For Trilinos container images there is a user `runner` that has UID:GID =
1000:1000.   And on WSL systems, you user is likely also UID:GID = 1000:000.  In
this case, you pass in `${USER}`.
