# school_website_results

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

for deploy on gh paged we do not need to push code on ghpage branch only build/web folder need to push on that branch 

flutter build web --release --base-href /school-app/

cd build/web
# Ensure your remote 'origin' here points to the correct project repository
# If you re-initialized git, you might need to add it again:
# git remote add origin https://github.com/<username>/<repository-name>.git
git push -f origin HEAD:gh-pages



git remote add origin https://github.com/DileepJexpert/school-app.git
