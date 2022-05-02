#!/usr/bin/env bash
set -o errexit  # exit on error
set -o errtrace  # enables ERR traps so we can run cleanup
set -o pipefail  # exit on error in a pipe, without this only the status of the last command in a pipe is considered
set -o nounset  # exit on undefined variables

shopt -s globstar

for filepath in **/*.instance.yml; do
    [ -f "$filepath"  ] || continue

    echo "executing $filepath"

    filename=$(basename "$filepath")
    instance_id="${filename%.instance.yml}"
    first_line=$(head -1 "$filepath")

    if [ "$first_line" = "#DELETED" ]; then
        unipipe update --instance-id "$instance_id" --status "succeeded" --description "destroyed" ../
        echo "$filepath is destroyed."
    else
        unipipe update --instance-id "$instance_id" --status "succeeded" --description "applied" ../
        echo "$filepath is applied."
    fi
    echo "----------------------------------------------------------------"
done