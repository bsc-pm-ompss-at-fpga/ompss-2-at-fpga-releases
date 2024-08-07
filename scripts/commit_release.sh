#!/bin/bash -e

if [ "$#" -ne "1" ]; then
  echo -e "USAGE:\t$0 <release version>"
  exit 0
fi
VERSION=$1

#NOTE: Ensure running in the repo root dir
pushd $(dirname ${BASH_SOURCE[0]})/../ >/dev/null

  CHANGELOG_VER=$(head -n1 Changelog.md | grep -oE "[0-9.]*(-rc[0-9]*)?")
  if [ "$CHANGELOG_VER" != "$VERSION" ] ; then
    echo -e "ERROR:\tThe changelog version does not match the release version"
    column -t -s ':' <<< "
    Changelog version: ${CHANGELOG_VER}
    Release version: ${VERSION}"
    exit
  fi

  CHANGELOG_DIFF=$(git diff Changelog.md)
  if [ "x$CHANGELOG_DIFF" == "x" ]; then
    echo -e "ERROR:\tThe changelog does not contain the release changes"
    exit 0
  fi

  # Set user-guide URL
  sed -i "s/\(user-guide-\)\([0-9]\|[.]\)*\(-rc[0-9]*\)\?/\1${VERSION}/" README.md

  # Enable the cache mode for credentials in meta-repository and every submodule
  git config credential.helper cache

  # If commiting a public release, create a release tag in each subrepo and push them
  # Also delete all release candidate tags from meta-repository
  if ! [[ ${VERSION} =~ [0-9]+\.[0-9]+\.[0-9]+-rc[0-9]* ]] ; then
    #git submodule foreach git config credential.helper cache
    #git submodule foreach git tag -m "OmpSs-2-at-FPGA release ${VERSION}" ompss-2-at-fpga-release/${VERSION}
    #git submodule foreach git push origin ompss-2-at-fpga-release/${VERSION}
    #git submodule foreach git credential-cache exit

    git push origin --delete $(git tag --list '[0-9]\.[0-9]\.[0-9]-rc[0-9]*')
    git tag --delete $(git tag --list '[0-9]\.[0-9]\.[0-9]-rc[0-9]*')
  fi

  # Stash the updated subrepos and commit the changes + create the tag
  git add ait llvm nanos6-fpga ompss-at-fpga-kernel-module xdma xtasks ovni Changelog.md README.md
  git commit -m "OmpSs-2-at-FPGA release ${VERSION}"
  git tag ${VERSION}
  git push origin master ${VERSION}

  # Clear the credentials cache
  git credential-cache exit

popd >/dev/null
