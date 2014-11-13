#!/bin/bash
SPEC=$1

if [ "$DELTA_BASE" != "" ] && [ "$DELTA_NAME" != "" ] && [ "DELTA_PASS" != "" ]
then
    rm -rf delta
    mkdir delta
    cd delta
    curl -s -o filelist -u "$DELTA_NAME:$DELTA_PASS" -s "$DELTA_BASE/filelist"
    for f in `cat filelist`; do
        curl -s -o $f -u "$DELTA_NAME:$DELTA_PASS" -s "$DELTA_BASE/$f"
    done
    make SPEC="$SPEC"
    cd ..
    mv delta/diff.html .
    rm -rf delta
else if [ -d "$DELTA_LOCAL" ]
then
    rm -rf delta
    mkdir delta
    cd delta
    for f in `cat $DELTA_LOCAL/filelist`; do
        cp "$DELTA_LOCAL/$f" .
    done
    make SPEC="$SPEC"
    cd ..
    mv delta/diff.html .
    rm -rf delta
fi
fi
