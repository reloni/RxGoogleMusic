#!/bin/bash
set -e

aws s3 sync s3://app-build-caches/RxGoogleMusic/Carthage/Build ./Carthage/Build/

(cd Carthage/Build/iOS/ && for i in `find . | grep -iE "(.framework.tar.gz|.dsym.tar.gz)$"`; do tar -xzf "$i" ; done)
(cd Carthage/Build/Mac/ && for i in `find . | grep -iE "(.framework.tar.gz|.dsym.tar.gz)$"`; do tar -xzf "$i" ; done)
