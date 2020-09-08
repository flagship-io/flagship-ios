set -eo pipefail

# Type a script or drag a script file from your workspace to insert its path.
UNIVERSAL_OUTPUTFOLDER=$PWD/build/universal
BUILD_FOLDER=$PWD/build


mkdir -p ${BUILD_FOLDER}

# make sure the output directory exists
mkdir -p "${UNIVERSAL_OUTPUTFOLDER}"



echo --------------
echo ${BUILD_ROOT}
echo --------------
echo ${BUILD_FOLDER}
echo --------------
echo --------------
echo ${PWD}
echo --------------
 





# Step 1. Build Device and Simulator versions
xcodebuild  build -project Flagship/Flagship.xcodeproj -scheme "Flagship"  -sdk iphoneos ONLY_ACTIVE_ARCH=NO  BUILD_DIR=${BUILD_FOLDER} BUILD_ROOT="${BUILD_ROOT}" CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO
 

xcodebuild  build -project Flagship/Flagship.xcodeproj -scheme "Flagship"  -sdk iphonesimulator -arch x86_64 ONLY_ACTIVE_ARCH=NO BUILD_DIR=${BUILD_FOLDER} BUILD_ROOT="${BUILD_ROOT}"

 

# Step 2. Copy the framework structure to the universal folder
cp -R ${BUILD_FOLDER}/Debug-iphoneos/Flagship.framework" "${UNIVERSAL_OUTPUTFOLDER}/"

echo  ------- After copy in the universsal 

# Step 3. Create universal binary file using lipo and place the combined executable in the copied framework directory
lipo -create -output "${UNIVERSAL_OUTPUTFOLDER}/Flagship.framework/Flagship" "${BUILD_FOLDER}/Debug-iphonesimulator/Flagship.framework/Flagship" "${BUILD_FOLDER}/Debug-iphoneos/Flagship.framework/Flagship"
