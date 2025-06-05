# Ross Bartlett's container tools

This little repo contains instructions and tools for setting up my dev env
inside of a container.

This repo should be cloned under the ~/personal_cygwin_laptop_home repo.  (That
can be done with the script ~/personal_cygwin_laptop_home/clone.repos.sh)

When opening the container, mount the directory with `docker run` (or `podman
run`) mounting the base repo with the argument:

```bash
  -v /home/<user-name>/personal_cygwin_laptop_home:/mounted/personal_cygwin_laptop_home
```

Then, once in the container, just do:

```bash
$ cd   # Takes you to /home/root/?
$ /mounted/personal_cygwin_laptop_home/rab_container_tools/set_up_home_dir_env.sh
```

and you can then load your env with:

```bash
$ bash   # Just in case you type exit by accident!
$ . .bash_profile
```

See that script for details about what it is doing!

To work on git repos setup to work with gitdist inside of the container, you
will need to run the script:

```bash
$ cd <base-repo>/
$ /mounted/personal_cygwin_laptop_home/rab_container_tools/gitdist_make_safe_repos.sh
```

NOTE: That script modifies the global `~/.gitconfig` file, but that file is just
a copy on the container (due to `set_up_home_dir_env.sh` above).  So it is
harmless.
