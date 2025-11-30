#!/bin/bash
# Clean extended attributes from Flutter framework before code signing
if [ -d "${BUILD_DIR}/Debug-iphonesimulator/Flutter.framework" ]; then
  xattr -cr "${BUILD_DIR}/Debug-iphonesimulator/Flutter.framework" 2>/dev/null || true
fi
if [ -d "${BUILD_DIR}/Release-iphonesimulator/Flutter.framework" ]; then
  xattr -cr "${BUILD_DIR}/Release-iphonesimulator/Flutter.framework" 2>/dev/null || true
fi
