#!/bin/bash
flutter build web --base-href="school-app"

git worktree add /tmp/gh-pages gh-pages || git checkout -b gh-pages
rm -rf /tmp/gh-pages/*
cp -r build/web/* /tmp/gh-pages/
cd /tmp/gh-pages
git add .
git commit -m "Deploy update"
git push origin gh-pages --force
cd -
git worktree remove /tmp/gh-pages
