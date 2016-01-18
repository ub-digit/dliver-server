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

if [ "$DLIVER_PACKAGES_GROUP" != "" ]
then
  echo "Setting new package group to: $DLIVER_PACKAGES_GROUP"
else
  echo "Environment variable DLIVER_PACKAGES_GROUP is not set"
  exit 1
fi


PACKAGE_PATH="$DLIVER_PACKAGES_DIR"/"$PACKAGE_NAME"

if [ ! -d "$PACKAGE_PATH" ]
then
  echo "$PACKAGE_PATH is not a valid directory"
  exit 2
fi

# Check if an unlock-file exists, which should cancel operation
if ls -a "$DLIVER_PACKAGES_DIR/.unlock_"* >/dev/null 2>&1
then
  echo "Unlock-file found in folder, cancelling operation"
  exit 3
fi

# Create file to visualize that package is unlocked and prevent more than one package to be unlocked at the same time.
UNLOCKED_FILE_NAME=".unlock_$PACKAGE_NAME"
touch "$DLIVER_PACKAGES_DIR"/"$UNLOCKED_FILE_NAME"

chgrp -R "$DLIVER_PACKAGES_GROUP" "$PACKAGE_PATH"
find "$PACKAGE_PATH" -type d -print0 | xargs -0 chmod g+ws
find "$PACKAGE_PATH" -type f -print0 | xargs -0 chmod g+w
