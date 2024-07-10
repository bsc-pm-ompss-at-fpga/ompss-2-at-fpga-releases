#!/bin/bash -e

git config credential.helper cache
git submodule sync
git submodule foreach git fetch -vp
git submodule foreach git pull
