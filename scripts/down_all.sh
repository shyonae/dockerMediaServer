#/bin/bash

for compose in $(find "$PWD/../" -type f -not -path '*.unused*' -name 'compose.yml' | sort -r); do
  infisical run -- docker compose -f $compose down
done
