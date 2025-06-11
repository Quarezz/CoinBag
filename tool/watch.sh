#!/bin/bash

echo "👀 Watching for changes..."
cd coinbag_flutter && fvm dart run build_runner watch --delete-conflicting-outputs 