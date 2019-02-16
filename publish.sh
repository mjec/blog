#!/usr/bin/env bash

pushd "$(dirname "$0")"
hugo

cd public
git add .
git commit -m "${1:-Update content}"
git push

cd ..
git add .
git commit -m "${1:-Update content}"
git push

popd
