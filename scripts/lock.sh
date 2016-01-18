#!/bin/bash

PACKAGE_NAME="$1"

if [ "$PACKAGE_NAME" != "" ]
then
  echo "Looking for package with name: $PACKAGE_NAME"
else
  echo "Missing variable 1, must be given as full name of package"
  exit 1
fi

if [ "$DLIVER_PACKAGES_DIR" != "" ]
then
  echo "Looking for packages in: $DLIVER_PACKAGES_DIR"
else
  echo "Environment variable DLIVER_PACKAGES_DIR is not set"
  exit 1
fi

PACKAGE_PATH="$DLIVER_PACKAGES_DIR/$PACKAGE_NAME"

echo "$PACKAGE_PATH"

if [ ! -d "$PACKAGE_PATH" ]
then
  echo "$PACKAGE_PATH is not a valid directory"
  exit 2
fi

chown -R root "$PACKAGE_PATH"
chmod -R g-w "$PACKAGE_PATH"

# Delete unlock file to be able to unlock another package
UNLOCKED_FILE_NAME=".unlock_$PACKAGE_NAME"
rm -f "$DLIVER_PACKAGES_DIR"/"$UNLOCKED_FILE_NAME"

