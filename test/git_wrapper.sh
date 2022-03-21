#!/usr/bin/bash
# A dumb thin wrapper around git that claims it's git 1.8.3

if [[ "$@" == "--version" ]]; then
    echo "git version 1.8.3"
else
    git $@
fi
