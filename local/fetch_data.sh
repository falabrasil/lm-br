#!/usr/bin/env bash
#
# author: 2021
# cassio batista - https://cassota.gitlab.io

SHA="MY_SHA"
BASE_URL=https://oscar-public.huma-num.fr/shuff-orig/pt

[[ "$SHA" == "MY_SHA" ]] && echo "$0: please set a proper cookie token" && exit 1

[ $# -ne 1 ] && echo "usage: $0 <data-dir>" && exit 1
dir=$1

mkdir -p $dir

for i in 10 20 30 40 50 60 ; do
  txt=pt_part_$i.txt
  [ ! -f $dir/$txt.gz ] && \
    { wget --header "Cookie: $SHA" $BASE_URL/$txt.gz -P $dir || exit 1 ; } || \
      echo "$0: file $txt.gz exists. skipping download"
  [ ! -f $dir/pt_part_$i.txt ] && gunzip -kv $dir/pt_part_$i.txt.gz || \
      echo "$0: file $txt exists. skipping decompression"
done
echo "$0: success!"
