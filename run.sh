#!/usr/bin/env bash
#
# Grupo FalaBrasil (2021)
# Universidade Federal do Pará (UFPA)
# Licença: MIT
#
# generates ARPA n-gram language models for speech recognition.
# a phonetic dictionary (lexicon) is also generated based on a
# vocabulary built over the same dataset used to train the LMs.
#
# author: oct 2021
# cassio batista - https://cassota.gitlab.io


function msg { echo -e "\e[$(shuf -i 92-96 -n 1)m[$(date +'%F %T')] $1\e[0m" ; }

stage=0
ns=70000000  # number of sentences supported on a 32 GB RAM machine. empirical
data=./data

# https://stackoverflow.com/questions/402377/using-getopts-to-process-long-and-short-command-line-options
while true ; do
  case $1 in
    -s | --stage) stage=$2; shift ;;
    *) break ;;
  esac
done


# check dependencies
if [ $stage -le 0 ] ; then
  msg "$0: checking dependencies"
  local/check_dependencies.sh || exit 1
fi

if [ $stage -le 1 ] ; then
  msg "$0: fetching oscar data (five parts only)"
  /usr/bin/time -f "Time: %E (%U secs). RAM: %M KB" \
    local/fetch_data.sh $data/raw || exit 1
fi

if [ $stage -le 2 ] ; then
  msg "$0: normalising data using five parallel jobs in background"
  mkdir -p $data/{log,norm}
  rm -f .err
  for i in 10 20 30 40 50 ; do
    ( /usr/bin/time -f "Time: %E (%U secs). RAM: %M KB" \
        local/norm_oscar.py \
          --log-file $data/log/pt_part_$i.log \
          $data/raw/pt_part_$i.txt \
          $data/norm/pt_part_$i.out || touch .err )&
  done
  wait
  [ -f .err ] && rm -f .err && \
    echo "$0: error during text normalisation" && exit 1
  msg "$0: shuffling and merging normalised files"
  /usr/bin/time -f "Time: %E (%U secs). RAM: %M KB" \
    cat $data/norm/*.out | shuf | head -n $ns > $data/corpus.txt
fi

# TODO stages 3 to 5 could be optimized by piping the former command's stdout
# to the next stdin's, therefore avoiding writing to disk.
#       r: file w:stdout            r:stdin w:stdout  r: file, stdin w:file
# e.g.: count_words.py corpus.txt | create_vocab.py | srilm_train.sh corpus.txt lmdir

if [ $stage -le 3 ] ; then
  msg "$0: counting words to create a frequency list"
  /usr/bin/time -f "Time: %E (%U secs). RAM: %M KB" \
    local/count_words.py $data/corpus.txt $data/count.txt || exit 1
fi

if [ $stage -le 4 ] ; then
  msg "$0: creating vocabulary of top-N most frequent words"
  /usr/bin/time -f "Time: %E (%U secs). RAM: %M KB" \
    local/create_vocab.py $data/count.txt $data/vocab.txt || exit 1
fi

# no need to use time profiler here as the script already does it
if [ $stage -le 5 ] ; then
  msg "$0: training n-gram language models with SRILM"
  echo >&2 "WARNING: this consumes *a lot* of RAM"
  local/srilm_train.sh $data/corpus.txt $data/vocab.txt $data/lm || exit 1
fi

if [ $stage -le 6 ] ; then
  msg "$0: building phonetic dictionary for vocab file (lexicon)"
  echo >&2 "WARNING: this will use as many threads as there are CPU cores"
  mkdir -p $data/{log,dict}
  cat $data/vocab.txt | \
    docker run --rm -i falabrasil/g2p 2> $data/log/g2p.log | \
    gzip -c > $data/dict/lexicon.txt.gz
  echo "$0: success! file '$data/dict/lexicon.txt.gz' saved."
fi

msg "$0: success!"
