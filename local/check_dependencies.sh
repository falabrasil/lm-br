#!/usr/bin/env bash
#
# author: oct 2021
# cassio batista - https://cassota.gitlab.io

ok=true
for pack in python3 aspell gzip wget ; do
  ! type -f $pack > /dev/null 2>&1 && ok=false && \
    echo "$0: error: please install $pack"
done
[ -z "$(aspell dicts | grep pt_BR)" ] && ok=false && \
  echo "$0: error: please install aspell's dictionary for portuguese"
[ ! -f /usr/bin/time ] && ok=false && echo "$0: error: please install time"
for mod in aspell num2words icu tqdm ; do
  ! python3 -c "import $mod" 2> /dev/null && ok=false && \
    echo "$0: error: please install python module $mod"
done
$ok && echo "$0: all good!" || exit 1
