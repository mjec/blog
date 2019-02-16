#!/usr/bin/env bash

pushd "$(dirname "$0")"
hugo

cd public
git commit -am "${1:-Update content}"
git push

cd ..
git commit -am "${1:-Update content}"
git push

popd
