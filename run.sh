#!/usr/bin/env bash
#
# author: oct 2021
# cassio batista - https://cassota.gitlab.io

function msg { echo -e "\e[$(shuf -i 92-96 -n 1)m[$(date +'%F %T')] $1\e[0m" ; }

stage=0
ns=75000000  # number of sentences supported on a 32 GB RAM machine. empirical
data=./data

# https://stackoverflow.com/questions/402377/using-getopts-to-process-long-and-short-command-line-options
while true ; do
  case $1 in
    -s | --stage) stage=$2; shift ;;
    *) break ;;
  esac
done

if [ $stage -le 0 ] ; then
  msg "$0: fetching oscar data (six parts only)"
  local/fetch_data.sh $data/raw || exit 1
fi

if [ $stage -le 1 ] ; then
  msg "$0: normalising data using six parallel jobs in background"
  mkdir -p $data/{log,norm}
  rm -f .err
  for i in 10 20 30 40 50 60 ; do
    ( local/norm_oscar.py \
        --log-file $data/log/pt_part_$i.log \
        $data/raw/pt_part_$i.txt \
        $data/norm/pt_part_$i.out || touch .err )&
  done
  wait
  [ -f .err ] && rm -f .err && \
    echo "$0: error during text normalisation" && exit 1
  msg "$0: shuffling and merging normalised files"
  cat $data/norm/*.out | shuf | head -n $ns > $data/corpus.txt
fi

if [ $stage -le 2 ] ; then
  msg "$0: counting words to create a frequency list"
  local/count_words.py $data/corpus.txt $data/count.txt || exit 1
fi

if [ $stage -le 3 ] ; then
  msg "$0: creating vocabulary of top-N most frequent words"
  local/create_vocab.py $data/count.txt $data/vocab.txt || exit 1
fi

if [ $stage -le 4 ] ; then
  msg "$0: training n-gram language models with SRILM"
  echo >&2 "WARNING: this consumes *a lot* of RAM"
  local/srilm_train.sh $data/corpus.txt $data/vocab.txt $data/lm || exit 1
fi

if [ $stage -le 5 ] ; then
  msg "$0: building phonetic dictionary for vocab file (lexicon)"
  cat $data/vocab.txt | docker run --rm -i falabrasil/g2p | \
    gzip -c > $data/lm/lexicon.txt.gz
fi

msg "$0: success!"
