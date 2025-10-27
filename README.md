# Container environment setup tools

This repository contains instructions and scripts for setting up a development
environment inside a container so it can run as a local user with the same UID
and GID as the host user. This is useful on systems where the host user's
UID:GID are not mapped to 0:0 (root) inside the container.

Adding a user inside the container with the same UID and GID ensures files
created or modified inside the container remain owned by the host user on the
host filesystem.

**Table of Contents:**

- [Container environment setup tools](#container-environment-setup-tools)
  - [Mount into docker container](#mount-into-docker-container)
  - [Build a derived container that adds a local user matching the host user UID and GID](#build-a-derived-container-that-adds-a-local-user-matching-the-host-user-uid-and-gid)
  - [Add a local user matching the host user UID and GID in a running container](#add-a-local-user-matching-the-host-user-uid-and-gid-in-a-running-container)
  - [Date tag and optionally remote tag and push a container image](#date-tag-and-optionally-remote-tag-and-push-a-container-image)
  - [Allow Git operations on mounted git repos for root user](#allow-git-operations-on-mounted-git-repos-for-root-user)

## Mount into docker container

This repo is intended to be cloned under a base repo `<personal-home-dir-setup>`
that contains your personal bash environment setup for a local machine (for
example, `~/rab_home_dir_setup/` for @bartlettroscoe, which results in
`~/rab_home_dir_setup/container_env_setup`).

When running the container, mount the base directory `<personal-home-dir-setup>`
read-only with `docker run` (or `podman run`) by adding:

```bash
  -v /home/<user-name>/<personal-home-dir-setup>:/mounted_from_host/<personal-home-dir-setup>:ro
```

(for example, `<personal-home-dir-setup>` = `rab_home_dir_setup` for
@bartlettroscoe)

This allows you to set up your custom bash environment from inside the
container.

## Build a derived container that adds a local user matching the host user UID and GID

To build a derived container that adds a user with the same UID and GID as the
host user, see the instructions in
[add_user_container_build/README.md](./add_user_container_build/README.md).

Once inside the container as the matching user, run:

```bash
cd ~
/mounted_from_host/<personal-home-dir-setup>/container_env_setup/setup_home_dir_env.sh
. .bash_profile
```

NOTE: This is the recommended way to set up a user in the container that
matches the host user's UID and GID.

## Add a local user matching the host user UID and GID in a running container

Instead of building a derived container with a matching user, you can run a
container as `root` and create a new user with the host user's UID and GID
inside the running container. This requires additional setup when launching the
container and is therefore not recommended in most cases.

If you prefer this route, once in the container as `root`, set up a local user
with the same UID and GID as the host user using:

```bash
/mounted_from_host/<personal-home-dir-setup>/container_env_setup/setup_container_as_local_uid_gid.sh
```

That script will create a new user with the same name as the host user or use
an existing container user that already has the same UID. It will also create
and/or reuse a group with the matching GID and add the local user to that
group if necessary.

After `setup_container_as_local_uid_gid.sh` has run, become the local user by
running:

```bash
~/become_localuser.sh [-p]
```

If `-p` is passed, the local user's `~/.bash_profile` is sourced. Otherwise
the local user's `~/.bashrc` is sourced when starting the new shell.

Once you are the local user, set up the home directory environment with:

```bash
./<personal-home-dir-setup>/container_env_setup/setup_home_dir_env.sh
```

After that, the local user's `~/.bash_profile` will load the custom
environment on next login, or you can load it manually with:

```bash
. .bash_profile
```

## Date tag and optionally remote tag and push a container image

This repo includes a small utility script, `date_tag_and_push_container_image.sh`, that
adds a date tag to a container image and can optionally add a remote tag and
push the remote-tagged image(s) as:

```bash
<this-dir>/date_tag_and_push_container_image.sh <image-name>:<image-tag> \
  [<remote-prefix> [<push-prefix>]]
```

For example, to add a date tag, remote tags, and push the remote-tagged
images for `my-container:latest`, run:

```bash
<this-dir>/date_tag_and_push_container_image.sh my-container:latest \
  bartlettroscoe push
```

This creates the following image tags with `docker tag`:

- `my-container:<YYYY>-<MM>-<DD>`
- `bartlettroscoe/my-container:latest`
- `bartlettroscoe/my-container:<YYYY>-<MM>-<DD>`

and pushes the latter two images with `docker push` when the `push` option is passed into the script.

NOTE: Make sure you create the container repositories on hub.docker.com (or
your chosen registry) before pushing.

## Allow Git operations on mounted git repos for root user

If you prefer to run as `root` in the container and don't want to create a
matching user in the container, you may need to tweak the usage of Git inside
the container. To make mounted git repositories safe for operations by `root`
and optionally to work with [TriBITS
`gitdist`](https://tribitspub.github.io/TriBITS/users_guide/index.html#gitdist-documentation)
tool  inside the container, run:

```bash
cd <base-git-repo>/
~/<personal-home-dir-setup>/container_env_setup/gitdist_make_safe_repos.sh
```

NOTE: That script modifies the (container) global `~/.gitconfig` file.  But that
file is a copy in the container (created by `setup_home_dir_env.sh`), so
modifications are harmless to the host.
