#!/bin/bash -e

git config credential.helper cache
git submodule foreach git config credential.helper cache
git submodule sync
git submodule foreach git fetch -vp
git submodule foreach git pull
git submodule foreach git credential-cache exit
git credential-cache exit
