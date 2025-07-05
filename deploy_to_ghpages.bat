@echo off
REM ===== Deploy Flutter Web to GitHub Pages =====

echo Building Flutter Web...
flutter build web --release --base-href="/school-app/"

REM Optional: copy 404.html if you use clean URLs
IF EXIST web\404.html (
    echo Copying 404.html...
    copy web\404.html build\web\
)

cd build\web

echo Initializing Git repo inside build/web...
git init
git checkout -b gh-pages
git remote add origin https://github.com/DileepJexpert/school-app.git

echo Adding and committing files...
git add .
git commit -m "Manual deploy of Flutter web to gh-pages"

echo Pushing to gh-pages branch...
git push -f origin gh-pages

cd ../..

echo.
echo ✅ Deployment Complete!
echo 🌐 Visit: https://dileepjexpert.github.io/school-app/
pause
