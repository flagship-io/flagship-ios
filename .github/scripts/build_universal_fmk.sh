set -eo pipefail

# Universal folder
UNIVERSAL_OUTPUTFOLDER=$PWD/build/universal

# build folder
BUILD_FOLDER=$PWD/build

# make sure the output build exists
mkdir -p ${BUILD_FOLDER}

# make sure the output universal exists
mkdir -p "${UNIVERSAL_OUTPUTFOLDER}"



# Step 1. Build Device and Simulator versions
xcodebuild  build -quiet  -project Flagship/Flagship.xcodeproj -scheme "Flagship"  -sdk iphoneos ONLY_ACTIVE_ARCH=NO  BUILD_DIR=${BUILD_FOLDER} BUILD_ROOT="${BUILD_ROOT}" CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO
 

xcodebuild  build -quiet -project Flagship/Flagship.xcodeproj -scheme "Flagship"  -sdk iphonesimulator -arch x86_64 ONLY_ACTIVE_ARCH=NO BUILD_DIR=${BUILD_FOLDER} BUILD_ROOT="${BUILD_ROOT}"

 

# Step 2. Copy the framework structure to the universal folder
cp -R "${BUILD_FOLDER}/Debug-iphoneos/Flagship.framework" "${UNIVERSAL_OUTPUTFOLDER}/"


# Step 3. Create universal binary file using lipo and place the combined executable in the copied framework directory
lipo -create -output "${UNIVERSAL_OUTPUTFOLDER}/Flagship.framework/Flagship" "${BUILD_FOLDER}/Debug-iphonesimulator/Flagship.framework/Flagship" "${BUILD_FOLDER}/Debug-iphoneos/Flagship.framework/Flagship"

cp -r "${BUILD_FOLDER}/Debug-iphonesimulator/Flagship.framework/Modules/Flagship.swiftmodule/" "${UNIVERSAL_OUTPUTFOLDER}/Flagship.framework/Modules/Flagship.swiftmodule"

echo ---- Before artifact -------
mkdir -p path/to/artifact
cp -R "/Users/runner/work/flagship-ios/flagship-ios/build/universal/Flagship.framework" "path/to/artifact/Flagship.framework"

echo ---- Done -------
