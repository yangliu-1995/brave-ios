#!/bin/bash

findCommand="find . -type d -maxdepth 1 -not -path ."
declare -a excludedDirectories=( 
  "ThirdParty"
  ".git"
  ".github"
  "build"
  "l10n"
  "fastlane"
  "node_modules"
  "*.xcodeproj"
)
for dir in "${excludedDirectories[@]}"; do
  findCommand="$findCommand ! -name $dir"
done

directoriesToFormat=`exec $findCommand`
swift format --in-place --recursive $directoriesToFormat