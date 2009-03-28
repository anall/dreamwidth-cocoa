#!/bin/sh
if [ -e live-config.sh ]; then
    . live-config.sh
fi
xcodebuild -project Dreamwidth/Dreamwidth.xcodeproj -configuration Debug -target Tests