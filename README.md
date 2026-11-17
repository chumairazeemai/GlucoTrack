# GlucoTrack (Flutter)

Blood sugar tracker for Android: mg/dL ⇄ mmol/L auto-conversion, fasting / non-fasting
status, today and 7-day averages, 7-day chart, history filters, profile with BMI,
and report export (copy, share, CSV). Data is stored on the phone.

## Get the APK without installing anything (GitHub Actions)
1. Create a free GitHub account and a new repository.
2. Upload everything in this folder (including the hidden `.github` folder) to it.
3. Open the repo's **Actions** tab → **Build Android APK** → **Run workflow**.
4. After ~5 minutes open the finished run and download **GlucoTrack-apk**. Unzip it,
   send `app-release.apk` to your phone, tap it, and allow "Install unknown apps" once.

## Or build on your computer
Install Flutter + Android Studio, then run `./setup_and_build.sh` in this folder.
