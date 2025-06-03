#!/usr/bin/env bash
set -e
if ! command -v flutter >/dev/null; then
  echo "Flutter SDK not found. Please install Flutter and ensure 'flutter' is in your PATH." >&2
  exit 1
fi
flutter test
