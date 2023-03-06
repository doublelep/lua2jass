#!/bin/env bash
# usage: PATCH_LVL=lvl process infile outfile <optional prefix>

#[ -z "${PATCH_LVL}" ] && echo "Error: No patch specified" && exit 1

scope=$(head -n1 "$1" | sed 's/^\/\/[[:blank:]]*scope[[:blank:]]*//')

cpp -DPATCH_LVL="$PATCH_LVL" "$1" \
  | sed 's/^#/\/\//' \
  | sed "s/\\(\\w\\+\\)\\(#\\|@\\)/${3}\\1/g" \
  | sed 's/__/\&\&/g' \
  | sed "s/\\b_/${3}${scope}_/g" \
  | sed 's/&&/__/g' > "$2"
  
