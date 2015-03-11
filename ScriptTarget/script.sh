#!/bin/sh

#  script.sh
#  Librelio
#
#  Copyright (c) 2013 WidgetAvenue - Librelio. All rights reserved.

PATH_TO_SOURCE=$(<"${SRCROOT}/ScriptTarget/path.txt")
echo "$PATH_TO_SOURCE"
cd "$PATH_TO_SOURCE"

#Compile xibs
for f in $(find "./" -type f -name "*.xib")
do
echo "Processing $f"
filename="${f%.xib}"
ibtool "$f" --compile "$filename.nib"

cp "${SRCROOT}/ScriptTarget/Xib-PartialInfo.plist" "${TARGET_TEMP_DIR}/$filename-PartialInfo.plist" #hack to avoid error when building
done

echo "Done processing xibs"
echo "${CONFIGURATION_TEMP_DIR}"

#Copy all resources
echo "rsync -r --del $PATH_TO_SOURCE/ ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/"
rsync -r --del "$PATH_TO_SOURCE/" ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/