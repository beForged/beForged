#!/bin/bash

# verify branch
git checkout master

# build new files
stack exec myblog clean
stack exec myblog build

# commit
git add -A
git commit -m "publish"

# push
git push origin master:master
