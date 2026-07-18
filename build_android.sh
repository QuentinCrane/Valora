#!/usr/bin/env bash
set -euo pipefail

if ! command -v flutter >/dev/null 2>&1; then
  echo "[ERROR] flutter command not found. Install Flutter stable and add it to PATH." >&2
  exit 1
fi

if [ ! -f android/app/build.gradle ] || [ ! -f android/settings.gradle ]; then
  echo "[ERROR] Android platform files are incomplete; refusing to overwrite local native changes." >&2
  echo "[HINT] In a Git checkout, run: git restore --source=HEAD --worktree -- android" >&2
  echo "[HINT] Otherwise, restore android from a clean checkout." >&2
  exit 1
fi

if [ ! -f android/gradlew ]; then
  echo "[ERROR] Gradle Wrapper is missing; refusing to overwrite local native changes." >&2
  echo "[HINT] In a Git checkout, run: git restore --source=HEAD --worktree -- android" >&2
  echo "[HINT] Otherwise, restore android from a clean checkout." >&2
  exit 1
fi

flutter doctor || true
flutter pub get
flutter analyze
flutter build apk --debug

echo "[SUCCESS] APK: build/app/outputs/flutter-apk/app-debug.apk"
