#!/bin/bash
set -e

export UPLOADPATH_IOS=$PWD/Carthage/Build/iOS/Upload
mkdir -p $UPLOADPATH_IOS

export UPLOADPATH_MAC=$PWD/Carthage/Build/Mac/Upload
mkdir -p $UPLOADPATH_MAC

(cd Carthage/Build/iOS/ && for i in `find . | grep -iE "(.framework|.dsym)$"`; do tar -zvc -f "$UPLOADPATH_IOS/$i.tar.gz" "$i" ; done)
aws s3 sync $UPLOADPATH_IOS s3://app-build-caches/RxGoogleMusic/Carthage/Build/iOS --delete
rm -rf $UPLOADPATH_IOS

(cd Carthage/Build/Mac/ && for i in `find . | grep -iE "(.framework|.dsym)$"`; do tar -zvc -f "$UPLOADPATH_MAC/$i.tar.gz" "$i" ; done)
aws s3 sync $UPLOADPATH_MAC s3://app-build-caches/RxGoogleMusic/Carthage/Build/Mac --delete
rm -rf $UPLOADPATH_MAC
