#!/bin/sh
# diff-lines.sh
path=
line=
minusline=
minus=0
while read; do
  esc=$'\033'
  if [[ "$REPLY" =~ ---\ (a/)?.* ]]; then
    continue
  elif [[ "$REPLY" =~ \+\+\+\ (b/)?([^[:blank:]]+).* ]]; then
    minus=0
    path=${BASH_REMATCH[2]}
  elif [[ "$REPLY" =~ @@\ -[0-9]+(,[0-9]+)?\ \+([0-9]+)(,[0-9]+)?\ @@.* ]]; then
    line=${BASH_REMATCH[2]}
    echo "$path:$line:$(( line - minus ))"
  elif [[ "$REPLY" =~ ^($esc\[[0-9;]+m)*([\ +-]) ]]; then
    if [[ "${BASH_REMATCH[2]}" == - ]]; then
      ((minus--))
    fi
  fi
done
