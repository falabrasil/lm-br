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


# path to common voice dataset in portuguese
CV_PATH=$HOME/common_voice/cv-corpus-7.0-2021-07-21/pt

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
          $data/raw/pt_part_$i.txt.gz \
          $data/norm/pt_part_$i.txt.gz || touch .err )&
  done
  wait
  [ -f .err ] && rm -f .err && \
    echo "$0: error during text normalisation" && exit 1
  msg "$0: shuffling and merging normalised files"
  /usr/bin/time -f "Time: %E (%U secs). RAM: %M KB" \
    gunzip -kc $data/norm/*.txt.gz | \
      shuf | head -n $ns | gzip -c > $data/corpus.txt.gz
fi

# TODO stages 3 to 5 could be optimized by piping the former command's stdout
# to the next stdin's, therefore avoiding writing to disk.
#       r: file w:stdout            r:stdin w:stdout  r: file, stdin w:file
# e.g.: count_words.py corpus.txt | create_vocab.py | srilm_train.sh corpus.txt lmdir

if [ $stage -le 3 ] ; then
  msg "$0: counting words to create a frequency list"
  /usr/bin/time -f "Time: %E (%U secs). RAM: %M KB" \
    local/count_words.py $data/corpus.txt.gz $data/count.txt.gz || exit 1
fi

if [ $stage -le 4 ] ; then
  msg "$0: creating vocabulary of top-N most frequent words"
  /usr/bin/time -f "Time: %E (%U secs). RAM: %M KB" \
    local/create_vocab.py $data/count.txt.gz $data/vocab.txt.gz 2> $data/log/vocab.log || exit 1
fi

# no need to use time profiler here as the script already does it
if [ $stage -le 5 ] ; then
  msg "$0: training n-gram language models with SRILM"
  echo >&2 "WARNING: this consumes *a lot* of RAM"
  local/srilm_train.sh $data/corpus.txt.gz $data/vocab.txt.gz $data/lm || exit 1
fi

if [ $stage -le 6 ] ; then
  msg "$0: evaluating language models"
  if [ ! -d $CV_PATH ] ; then
    echo "$0: error: common voice portuguese dataset not found under '$CV_PATH'"
    echo "$0: skipping lm evaluation..."
  else
    cut -f 3 $CV_PATH/test.tsv | sed 's/['\''«»"”?!,;:\.]//g' | \
      awk '{print tolower($0)}' | tail -n +2 > $data/cv_test.txt
    gunzip -kc $data/lm/3-gram.*.arpa.gz | sed "s/<unk>/<UNK>/g" | \
      ngram -memuse -lm - -order 3 -unk -ppl $data/cv_test.txt
    gunzip -kc $data/lm/4-gram.*.arpa.gz | sed "s/<unk>/<UNK>/g" | \
      ngram -memuse -lm - -order 4 -unk -ppl $data/cv_test.txt
  fi
fi

msg "$0: success!"
