#!/bin/bash

#----------------------------------------------------------------------------------
# set the release SDK version
#----------------------------------------------------------------------------------
if [ "$#" -eq  "1" ];
then
    releaseSDKVersion="$1"
else
read  -p "Please set the new FlagShip release version (ex: 1.1.0): " releaseSDKVersion;
fi

varComps=( ${releaseSDKVersion//./ } )

if (( ${#varComps[@]} != 3 )); then
    printf "\n[ERROR] Ouups .... Invalid target version : ${releaseSDKVersion} \n"
    exit 1
fi

cd "$(dirname $0)/.."

 # update FLagShip version in FlagShipVersion

sdkVersionFilepath="Source/Utils/FlagShipVersion.swift"
sdkVersionKey="FlagShipVersion"

printf "\tUpdating ${sdkVersionKey} to ${releaseSDKVersion}.\n"
sed -i '' -e "s/${sdkVersionKey}[ ]*=.*\"\(.*\)\"/${sdkVersionKey} = \"${releaseSDKVersion}\"/g" ${sdkVersionFilepath}

printf "Verifying ${sdkVersionKey} from ${sdkVersionFilepath}\n";
verifySdkVersion=$(sed -n "s/.*${sdkVersionKey} = \"\(.*\)\".*/\1/p" ${sdkVersionFilepath})

if [ "${verifySdkVersion}" == "${releaseSDKVersion}" ]
then
    printf "\tSDKVersion.swift file verified: ${releaseSDKVersion} === ${verifySdkVersion}\n"
else
    printf "\n[ERROR] SDKVersion.swift file has an error: [${verifySdkVersion}]";
    exit 1
fi


# 2. update the FlagShip version in podspecs

printf "\n\nReplacing versions in *.podspec files\n"

curPodSpec="Flagship.podspec"

printf "\t[${curPodSpec}] Updating podspec to ${releaseSDKVersion}.\n"
sed -i '' -e "s/\(s\.version[ ]*\)=[ ]*\".*\"/\1= \"${releaseSDKVersion}\"/g" ${curPodSpec}

# pod-spec-lint cannot be run here due to dependency issues
# all podspecs will be validated anyway when uploading to CocoaPods repo

printf "Verifying Flagship.podspec files\n"

vm=$(sed -n "s/s\.version.*=.*\"\(.*\)\"/\1/p" ${curPodSpec} | sed "s/ //g" )
echo $vm
if [ "${vm}" == "${releaseSDKVersion}" ]; then
    printf "\t[${curPodSpec}] Verified podspec: ${vm} === ${releaseSDKVersion}\n"
fi

printf "\n\n[SUCCESS] All release-sdk-version settings have been updated successfully!\n\n\n"
