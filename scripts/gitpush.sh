#!/bin/bash -e

GIT_MESSAGE=$1
if [ -z $GIT_MESSAGE ]
then
    GIT_MESSAGE=YOLO
fi

git add .
git commit -m "$GIT_MESSAGE"
git push
