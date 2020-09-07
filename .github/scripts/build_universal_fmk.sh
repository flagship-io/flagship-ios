set -eo pipefail

# Type a script or drag a script file from your workspace to insert its path.
UNIVERSAL_OUTPUTFOLDER=$PWD/build/universal

mkdir -p  $PWD/build

# make sure the output directory exists
mkdir -p "${UNIVERSAL_OUTPUTFOLDER}"

# Step 1. Build Device and Simulator versions
xcodebuild  build -project Flagship/Flagship.xcodeproj -scheme "Flagship"  -sdk iphoneos ONLY_ACTIVE_ARCH=NO  BUILD_DIR="build" BUILD_ROOT="${BUILD_ROOT}" CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO
 

xcodebuild  build -project Flagship/Flagship.xcodeproj -scheme "Flagship"  -sdk iphonesimulator -arch x86_64 ONLY_ACTIVE_ARCH=NO BUILD_DIR="build" BUILD_ROOT="${BUILD_ROOT}"

echo $BUILD_DIR
echo trace --------------

# Step 2. Copy the framework structure to the universal folder
cp -R "$PWD/build/Debug-iphoneos/Flagship.framework" "${UNIVERSAL_OUTPUTFOLDER}/"

# Step 3. Create universal binary file using lipo and place the combined executable in the copied framework directory
lipo -create -output "${UNIVERSAL_OUTPUTFOLDER}/Flagship.framework/Flagship" "$PWD/build/Debug-iphonesimulator/Flagship.framework/Flagship" "$PWD/build/Debug-iphoneos/Flagship.framework/Flagship"

#cp -r "${BUILD_DIR}/Debug-iphonesimulator/Flagship.framework/Modules/Flagship.swiftmodule/" "${UNIVERSAL_OUTPUTFOLDER}/Flagship.framework/Modules/Flagship.swiftmodule"
