#!/usr/bin/env bash
set -euo pipefail

if ! command -v flutter >/dev/null 2>&1; then
  echo "[ERROR] flutter command not found. Install Flutter stable and add it to PATH." >&2
  exit 1
fi

repair_android_shell() {
  echo "[INFO] Re-applying Valora Android patch files."
  cp -a tooling/android_patch/app android/
  cp -a tooling/android_patch/build.gradle android/build.gradle
  cp -a tooling/android_patch/settings.gradle android/settings.gradle
  cp -a tooling/android_patch/gradle.properties android/gradle.properties
}

if [ ! -f android/gradlew ]; then
  echo "[INFO] Gradle Wrapper not found. Running flutter create to repair Android build shell."
  flutter create --platforms=android --project-name valora_assets --org com.valora .
  repair_android_shell
fi

flutter doctor || true
flutter pub get
flutter analyze
flutter build apk --debug

echo "[SUCCESS] APK: build/app/outputs/flutter-apk/app-debug.apk"
