#!/bin/bash

cd coinbag_flutter

echo "🧹 Cleaning Flutter build..."
fvm flutter clean

echo "📦 Getting dependencies..."
fvm flutter pub get

echo "🏗️ Generating code..."
fvm flutter pub run build_runner build --delete-conflicting-outputs

echo "✅ All done!" 