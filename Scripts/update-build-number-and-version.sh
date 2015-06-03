# Auto Increment Build Number and Version
buildPlist=$SRCROOT/$INFOPLIST_FILE
PlistBuddy="/usr/libexec/PlistBuddy"

CFBundleVersion=`git --git-dir="$SRCROOT/.git" log --oneline | wc -l | tr -d '[:space:]'`
CFBundleShortVersionString=`git --git-dir="$SRCROOT/.git" describe --tags | sed -e 's/^v//'`
$PlistBuddy -c "Set :CFBundleVersion $CFBundleVersion" "$buildPlist"
$PlistBuddy -c "Set :CFBundleShortVersionString $CFBundleShortVersionString" "$buildPlist"
