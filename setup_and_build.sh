#!/usr/bin/env bash
# Local build (needs Flutter SDK + Android SDK installed). Run from this folder.
set -e
cp -r lib /tmp/gt_lib && cp pubspec.yaml /tmp/gt_pubspec.yaml
flutter create --platforms=android --project-name glucotrack --org com.glucotrack .
rm -rf lib test && cp -r /tmp/gt_lib lib && cp /tmp/gt_pubspec.yaml pubspec.yaml
sed -i 's/android:label="[^"]*"/android:label="GlucoTrack"/' android/app/src/main/AndroidManifest.xml
flutter pub get
dart run flutter_launcher_icons
flutter build apk --release
echo "APK: build/app/outputs/flutter-apk/app-release.apk"
