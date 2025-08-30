@echo off
echo ==== Building Flutter Web ====
flutter build web --release --base-href "/school-app/"

cd build\web

echo ==== Initializing Git in build/web ====
git init
git remote add origin https://github.com/DileepJexpert/school-app.git
git checkout -b gh-pages

echo ==== Adding and committing files ====
git add .
git commit -m "Deploy to GitHub Pages"

echo ==== Pushing to gh-pages branch ====
git push -f origin gh-pages

echo ==== Cleaning up ====
rd /s /q .git

echo ✅ Deployment complete!
echo 🔗 https://DileepJexpert.github.io/school-app/
