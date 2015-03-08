#!/bin/bash
# Copy Info Plist from template
OIFS=$IFS
IFS="/"
arrIN=(${INFOPLIST_FILE})
IFS=$OIFS

pListName=${arrIN[${#arrIN[@]} - 1]}
tmplPListName=${INFOPLIST_FILE/$pListName/Tmpl-$pListName}

echo Copying $SRCROOT/$tmplPListName into $SRCROOT/$INFOPLIST_FILE
`cp "$SRCROOT/$tmplPListName" "$SRCROOT/$INFOPLIST_FILE"`
