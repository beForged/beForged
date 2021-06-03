#!/bin/bash

# verify branch
git checkout master

# build new files
stack exec myblog clean
stack exec myblog build

# commit
git add -A
git commit -m $1

# push
git push origin master:master
