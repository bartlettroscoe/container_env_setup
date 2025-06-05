#/bin/bash
#
# Run this from the base git repo of a bunch of git repos to make them usable
# from inside of a container running as root:
#
#  $ cd ~ $ <this-dir>/gitdist_make_safe_repos.sh
#
# NOTE: This will update your base ~/.gitconfig file, so if that file is version
# controlled on the host machine then you will need to revert it.
#
for repo in $(cat .gitdist) ; do
  if [[ -d $repo ]] ; then
    cd $repo &> /dev/null 
    echo "git config --global --add safe.directory ${PWD}"
    git config --global --add safe.directory ${PWD}
    cd - &> /dev/null
  fi
done
