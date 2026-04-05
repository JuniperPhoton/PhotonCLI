#!/bin/zsh
set -e

SCHEME="PhotonCLI"
PROJECT="PhotonCLI.xcodeproj"
ARCHIVE_PATH="/tmp/${SCHEME}.xcarchive"
OUTPUT_DIR="$(dirname "$0")/Release"

echo "Archiving $SCHEME..."

xcodebuild archive \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration Release \
    -archivePath "$ARCHIVE_PATH" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=NO

BINARY=$(find "$ARCHIVE_PATH" -type f -name "$SCHEME" | head -1)

mkdir -p "$OUTPUT_DIR"
cp "$BINARY" "$OUTPUT_DIR/$SCHEME"
strip "$OUTPUT_DIR/$SCHEME"

rm -rf "$ARCHIVE_PATH"

echo "Done: $OUTPUT_DIR/$SCHEME"
