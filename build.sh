#!/bin/zsh
set -e
cd "$(dirname "$0")"

APP="NapBar.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"

BUILD=$(mktemp -d)
swiftc -O -target arm64-apple-macos13 -o "$BUILD"/napbar-arm64 main.swift
swiftc -O -target x86_64-apple-macos13 -o "$BUILD"/napbar-x86_64 main.swift
lipo -create "$BUILD"/napbar-arm64 "$BUILD"/napbar-x86_64 -output "$APP/Contents/MacOS/NapBar"

cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key><string>NapBar</string>
    <key>CFBundleIdentifier</key><string>com.acarmucahit.napbar</string>
    <key>CFBundleExecutable</key><string>NapBar</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleShortVersionString</key><string>1.0.0</string>
    <key>LSMinimumSystemVersion</key><string>13.0</string>
    <key>LSUIElement</key><true/>
</dict>
</plist>
PLIST

codesign --force --sign - "$APP"
echo "Built: $APP"
