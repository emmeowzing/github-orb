#! /bin/bash

git fetch --all --tags
RES="$(git show-ref --tags)"

if [ -z "$RES" ]; then
    NEW_TAG="v1.0.0"
else
    mapfile -d " " -t LATEST_TAG < <(git tag | sort -V | tail -1 | sed 's/\./ /g')

    if [ "${#LATEST_TAG[@]}" -ne 3 ]; then
        printf "Must follow semver convention /v?[0-9]{3}.[0-9]{3}.[0-9]{3}/ to parse.\\n" 1>&2
        exit 1
    fi

    one="${LATEST_TAG[0]//v/}"
    two="${LATEST_TAG[1]}"
    three="${LATEST_TAG[2]}"

    # Increment versions mod 1k.
    if [ "$three" == "999" ]; then
        if [ "$two" == "999" ]; then
            three=0
            two=0
            ((one++))
        else
            ((two++))
            three=0
        fi
    elif [ "$two" == "999" ] && [ "$three" == "999" ]; then
        ((one++))
        two=0
    else
        ((three++))
    fi

    NEW_TAG="v${one}.${two}.${three}"
fi

git tag "$NEW_TAG"
git push origin "$NEW_TAG"
