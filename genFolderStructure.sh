#!/usr/bin/env bash

set -euo pipefail

cd -- "$( dirname -- "${BASH_SOURCE[0]}" )"
DIR="$(pwd)"
WORK="$DIR/_work/"
mkdir -p "$WORK"
genPNGs() {
    cd "spdx-3-model"
    git log --follow --oneline -- model.png |
        while read line; do
            hash="$(echo "$line"|awk '{print $1;}')"
            num="$(printf "%03d\n" "$(git rev-list --count "$hash")")"
            date="$(git show -s --format=%cd --date=short "$hash")"
            description="$line"
            >&2 echo "$hash ($num) -> $description"

            outFile="$WORK/${num}-model@${hash}.png"
            git show "${hash}:model.png" > "$outFile"

            annotatedOutFile="$WORK/${num}-model@${hash}-annotated.png"
            convert "$outFile" \
                -pointsize 35 \
                -background White  label:"$date: $description" \
                -gravity Center \
                -append \
                "$annotatedOutFile"
            echo "$annotatedOutFile"
        done |
        xargs
}
genPDF() {
    convert $(genPNGs) "$DIR/model.pdf"
}

genPDF
