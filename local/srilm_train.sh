#!/usr/bin/env bash
#
# trains a pruned 3-gram and an unpruned 4-gram LMs
# using SRILM for 1st pass decoding and 2nd pass 
# lattice rescoring, respectively
#
# author: may 2021
# cassio batista - https://cassota.gitlab.io

set -e

! type -f ngram-count > /dev/null 2>&1 && \
  echo "$0: error: please install SRILM and set up your \$PATH" && exit 1

if [ $# -ne 3 ] ; then
    echo "usage: $0 <corpus-file> <vocab-file> <out-dir>"
    echo "e.g.: $0 $HOME/corpus.txt $HOME/vocab.txt $HOME/lm/"
    exit 1
fi

corpus_file=$1
vocab_file=$2
out_dir=$3
mkdir -p $out_dir

# unpruned four-gram LM for 2nd pass decoding (lattice rescoring)
echo "[$(date)] $0: training 4-gram"
/usr/bin/time -f "4-gram estimation took %E (%U secs)\tRAM: %M KB" \
    ngram-count \
        -memuse \
        -order 4 \
        -kndiscount \
        -interpolate \
        -unk \
        -map-unk "<UNK>" \
        -limit-vocab \
        -vocab $vocab_file \
        -text $corpus_file \
        -lm $out_dir/4-gram.arpa.gz || \
          { echo "$0: error building 4-gram lm" && exit 1 ; }

# NOTE: 1e-7 == 0.0000001 ?
# pruned trigram LM for 1st pass decoding
# unpruned version may be too big for reasonable decode time,
# so it has to be pruned for faster decoding
echo "[$(date)] $0: pruning 4-gram and reducing order to 3"
/usr/bin/time -f "3-gram estimation took %E (%U secs)\tRAM: %M KB" \
    ngram \
        -memuse \
        -order 3 \
        -prune 1e-7 \
        -lm $out_dir/4-gram.arpa.gz \
        -write-lm $out_dir/3-gram.1e-7.arpa.gz || \
          { echo "error pruning 3-gram lm" && exit 1 ; }

echo "[$(date)] $0: done!"
