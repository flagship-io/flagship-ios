#!/bin/bash

set -eo pipefail

# Type a script or drag a script file from your workspace to insert its path.
UNIVERSAL_OUTPUTFOLDER=$PWD/build/${CONFIGURATION}-universal

# make sure the output directory exists
mkdir -p "${UNIVERSAL_OUTPUTFOLDER}"

# Step 1. Build Device and Simulator versions
xcodebuild -target "Flagship" ONLY_ACTIVE_ARCH=NO -configuration ${CONFIGURATION} -sdk BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}" clean build

xcodebuild -target "Flagship" -configuration ${CONFIGURATION} -sdk  -arch x86_64 BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}" clean build

# Step 2. Copy the framework structure to the universal folder
cp -R "${BUILD_DIR}/${CONFIGURATION}-iphoneos/Flagship.framework" "${UNIVERSAL_OUTPUTFOLDER}/"

# Step 3. Create universal binary file using lipo and place the combined executable in the copied framework directory
lipo -create -output "${UNIVERSAL_OUTPUTFOLDER}/Flagship.framework/Flagship" "${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/Flagship.framework/Flagship" "${BUILD_DIR}/${CONFIGURATION}-iphoneos/Flagship.framework/Flagship"

cp -r "${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/Flagship.framework/Modules/Flagship.swiftmodule/" "${UNIVERSAL_OUTPUTFOLDER}/Flagship.framework/Modules/Flagship.swiftmodule"
