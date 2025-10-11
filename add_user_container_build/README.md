# Build derived container that adds a user and related stuff

To build a derived container that adds a user to the container that matches the
UID and GID of the host user, and starts the container as that new user, first
CD to the base repo `container_env_setup` as:

```bash
cd container_env_setup/
```

then build a derived container using the script
[`build_container.sh`](./build_container.sh) as:

```bash
./add_user_container_build/build_container.sh \
  codex-mull-trilinos-clang-18.1.8-openmpi-4.1.6:latest \
  ${USER}
```

NOTE: This also add date tag `<YYYY>-<MM>-<DD>` for the image.

NOTE: If there is already a user `<existing-user>` in the base image that
matches the UID and GID of the host user `${USER}`, then use that user name
`<existing-user>` instead of `${USER}` above.  In this case, the only effect
will be to set the default user as `<existing-user>`.

NOTE: For Trilinos container there is a user `runner` that has UID:GID =
1000:1000.   And on WSL systems, you user is likely also UID:GID = 1000:000.  In
this case, you pass in `${USER}`.
