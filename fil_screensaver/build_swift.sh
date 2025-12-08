#!/bin/bash

APP_NAME="fil_screensaver"
BUNDLE_ID="com.daito.filscreensaver"
DST="."

# Cleanup
rm -rf "$APP_NAME.saver" "$APP_NAME.pkg"
mkdir -p "$APP_NAME.saver/Contents/MacOS"
mkdir -p "$APP_NAME.saver/Contents/Resources"

# Compile
# Target macOS 12.0 for Canvas support
# -emit-library produces the binary
swiftc Sources/*.swift \
    -target arm64-apple-macosx12.0 \
    -emit-library \
    -module-name $APP_NAME \
    -o "$APP_NAME.saver/Contents/MacOS/$APP_NAME"

# Copy Resources
cp Info.plist "$APP_NAME.saver/Contents/"
cp Resources/* "$APP_NAME.saver/Contents/Resources/"

# Package
pkgbuild --root "$APP_NAME.saver" \
    --install-location "/Library/Screen Savers/$APP_NAME.saver" \
    --identifier "$BUNDLE_ID" \
    "$APP_NAME.pkg"

echo "Done. Created $APP_NAME.pkg"
