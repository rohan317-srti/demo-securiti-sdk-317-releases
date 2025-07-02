#!/bin/sh

#  create_framework.sh
#  ConsentCore
#
#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status
set -x  # Print commands and their arguments as they are executed

unset MACOSX_DEPLOYMENT_TARGET
unset TVOS_DEPLOYMENT_TARGET
unset WATCHOS_DEPLOYMENT_TARGET
unset DRIVERKIT_DEPLOYMENT_TARGET

# Define variables
PROJECT_NAME="DemoSecuritiSDK317"
SCHEME_NAME="DemoSecuritiSDK317"
SRCROOT="$(pwd)"
BUILD_DIR="${SRCROOT}/build"
IOS_SIMULATOR_ARCHIVE_PATH="$BUILD_DIR/${PROJECT_NAME}-iOS_Simulator.xcarchive"
IOS_DEVICES_ARCHIVE_PATH="$BUILD_DIR/${PROJECT_NAME}-iOS_Devices.xcarchive"
XCFRAMEWORK_PATH="$BUILD_DIR/${PROJECT_NAME}.xcframework"

# Clean previous build artifacts
rm -rf "$BUILD_DIR"

# Build for iOS Simulator
xcodebuild archive \
    -project "${SRCROOT}/../${PROJECT_NAME}.xcodeproj" \
    -scheme "$SCHEME_NAME" \
    -configuration Release \
    -destination "generic/platform=iOS Simulator" \
    -archivePath "$IOS_SIMULATOR_ARCHIVE_PATH" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# Build for iOS Devices with dynamic code signing
XCODEBUILD_ARGS=(
    -project "${SRCROOT}/../${PROJECT_NAME}.xcodeproj"
    -scheme "$SCHEME_NAME"
    -configuration Release
    -destination "generic/platform=iOS"
    -archivePath "$IOS_DEVICES_ARCHIVE_PATH"
    SKIP_INSTALL=NO
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES
)

# Add code signing parameters - use manual signing
XCODEBUILD_ARGS+=(CODE_SIGN_STYLE="Manual")

# Use CODE_SIGN_IDENTITY from environment or fallback to distribution certificate
if [ -n "$CODE_SIGN_IDENTITY" ]; then
    XCODEBUILD_ARGS+=(CODE_SIGN_IDENTITY="$CODE_SIGN_IDENTITY")
else
    XCODEBUILD_ARGS+=(CODE_SIGN_IDENTITY="Apple Distribution: Securiti, Inc. (8X6H793R4U)")
fi

if [ -n "$DEVELOPMENT_TEAM" ]; then
    XCODEBUILD_ARGS+=(DEVELOPMENT_TEAM="$DEVELOPMENT_TEAM")
fi

xcodebuild archive "${XCODEBUILD_ARGS[@]}"
    

# Set read and write permissions for archives
chmod +rw "$IOS_SIMULATOR_ARCHIVE_PATH"
chmod +rw "$IOS_DEVICES_ARCHIVE_PATH"

# module name
MODULE_NAME="DemoSecuritiSDK317"

# Create XCFramework
xcodebuild -create-xcframework \
    -framework "$IOS_SIMULATOR_ARCHIVE_PATH/Products/Library/Frameworks/${MODULE_NAME}.framework" \
    -framework "$IOS_DEVICES_ARCHIVE_PATH/Products/Library/Frameworks/${MODULE_NAME}.framework" \
    -output "$XCFRAMEWORK_PATH"

echo "Universal framework created at $XCFRAMEWORK_PATH"
