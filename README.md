# Container environment setup tools

This repo contains instructions and scripts for setting up a development
environment inside of a container to run as a local user with the same UID and
GID as the host user.

This sets up the container so that it creates files with the same UID and GID as
the local user launching the container.

**Table of Contents:**

- [Container environment setup tools](#container-environment-setup-tools)
  - [Mount into docker container](#mount-into-docker-container)
  - [Build a derived container that adds a local user matching the host user UID and GID](#build-a-derived-container-that-adds-a-local-user-matching-the-host-user-uid-and-gid)
  - [Add a local user matching the host user UID and GID in a running container](#add-a-local-user-matching-the-host-user-uid-and-gid-in-a-running-container)
  - [Date tag and optionally remote tag and push a container image](#date-tag-and-optionally-remote-tag-and-push-a-container-image)
  - [Allow Git operations on mounted git repos for root user](#allow-git-operations-on-mounted-git-repos-for-root-user)

## Mount into docker container

This repo should be cloned under the a base repo `<personal-home-dir-setup>`
containing your personal env setup for a local machine (e.g.,
`~/rab_home_dir_setup/` for @bartlettroscoe and therefore
`~/rab_home_dir_setup/container_env_setup`).

When running the container, mount the base directory read-only with `docker run`
(or `podman run`) by adding:

```bash
  -v /home/<user-name>/<personal-home-dir-setup>:/mounted_from_host/<personal-home-dir-setup>:ro
```

(e.g., `<personal-home-dir-setup>` = `rab_home_dir_setup` for @bartlettroscoe)

## Build a derived container that adds a local user matching the host user UID and GID

To build a derived container that adds a user with the same UID and GID as the
host user, see the instructions in
[add_user_container_build/README.md](./add_user_container_build/README.md).

## Add a local user matching the host user UID and GID in a running container

On can also set up a user in a running container that the UID and GUI of the
host user.  While one can do this, it is recommended to build a derived
container as described above.

Once in the container as `root`, first set up a local user in the container with
the same UID and GUD as the host user using:

```bash
/mounted_from_host/<personal-home-dir-setup>/container_env_setup/setup_container_as_local_uid_gid.sh
```

That will set up a new user with the same name as the host user, or use an
existing user in the container that has the same UID.  This will also create a
new group with GID if it does not already exist and add the local user to that
group (if a group with that GID does not already exist).

Once `setup_container_as_local_uid_gid.sh` has been run, as `root`, become the
local user by running:

```bash
~/become_localuser.sh [-p]
```

If the argument [-p] is passed in, then the local user's `.bash_profile` file is
sourced.  Otherwise, the local user's `.bashrc` file is sourced when running the
new shell.

Once becoming the local user, set up its home dir env using:

```bash
./<personal-home-dir-setup>/container_env_setup/setup_home_dir_env.sh
```

After that, the local user's `.bash_profile` fill will load the local users
custom env.

NOTE: Without setting up and using a local user with the same UID and GID as the
host user, running as `root` in the container will result in `root` owning any
files or directories it creates or modifies.  This will result in the host user
outside of the container not being able to change, delete, or even read those
files (depending on the permissions) which were changed or created by the `root`
user inside of the container. 

## Date tag and optionally remote tag and push a container image

To add a date tag for a given container image and optionally remote tag and push
the remote-tagged container iamges, run:

```bash
<this-dir>/date_tag_and_push_container_image <image-name>:<image-tag> \
  [<remote-prefix> [<push-prefix>]]
```

For example, date and remote tag and push the image `my-container:latest`, run:

```bash
<this-dir>/date_tag_and_push_container_image my-container:latest \
  bartlettroscoe push
```

This creates the following image tags with `docker tag`:

* `my-container:<YYYY>-<MM>-<DD>`
* `bartlettroscoe/my-container:latest`
* `bartlettroscoe/my-container:<YYYY>-<MM>-<DD>`

and pushes the latter two with `docker push`.

NOTE: Make sure you first create the container repositories on hub.docker.com,
or whatever container repository you are pushing to, before calling this.

## Allow Git operations on mounted git repos for root user

If running as `root` in the container, to work on Git repos setup to work with
gitdist inside of the container, you will need to run the script:

```bash
cd <base-git-repo>/
~/<personal-home-dir-setup>/container_env_setup/gitdist_make_safe_repos.sh
```

NOTE: That script modifies the global `~/.gitconfig` file, but that file is just
a copy on the container (due to `set_up_home_dir_env.sh` above).  So it is
harmless.
