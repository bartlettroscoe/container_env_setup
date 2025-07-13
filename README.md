# Container environment setup tools

This repo contains instructions and scripts for setting up a development
environment inside of a container to run as a local user with the same UID and
GID as the host user.

This sets up the container so that it creates files with the same UID and GID as
the local user launching the container.  

## Docker mounts

This repo should be cloned under the a base repo `<personal-home-dir-setup>`
containing your personal env setup with (e.g., `~/rab_home_dir_setup/` for
@bartlettroscoe) setup the local machine`.

When opening the container, mount the base directory with `docker run` (or
`podman run`) with the `docker run` argument:

```bash
  -v /home/<user-name>/<personal-home-dir-setup>:/mounted_from_host/<personal-home-dir-setup>
```

(e.g., `<personal-home-dir-setup>` = `rab_home_dir_setup`)

## Setting up a local user in the container

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

## Allow Git operations on mounted git repos

If running as `root`, to work on git repos setup to work with gitdist inside of
the container, you will need to run the script:

```bash
cd <base-git-repo>/
~/<personal-home-dir-setup>/container_env_setup/gitdist_make_safe_repos.sh
```

NOTE: That script modifies the global `~/.gitconfig` file, but that file is just
a copy on the container (due to `set_up_home_dir_env.sh` above).  So it is
harmless.
