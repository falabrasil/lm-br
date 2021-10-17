#!/usr/bin/env python3
#
# creates a vocabulary file (list of words) filtered 
# by aspell combined with a frequency-based threshold
#
# author: oct 2021
# cassio batista - https://cassota.gitlab.io

import sys
import re
import argparse
import logging

import aspell
import icu

logging.basicConfig(level=logging.INFO)

parser = argparse.ArgumentParser(
        description="filter frequency list with GNU Aspell")
parser.add_argument("count_file", help="input file")
parser.add_argument("vocab_file", help="output file")
parser.add_argument("--min-freq", default=300,
        help="minimum frequency required for a word not be filtered out")
parser.add_argument("--size", default=250000,
        help="vocab size (default: 250k)")

args = parser.parse_args()


if __name__ == "__main__":

    spell = aspell.Speller( ('lang', 'pt_BR'), ('ignore-case', 'true') )
    collator = icu.Collator.createInstance(icu.Locale('pt_BR.UTF-8'))

    logging.info("loading file: %s" % args.count_file)
    count = {}
    with open(args.count_file) as f:
        for line in f:
            word, freq = line.split()
            count[word] = int(freq)

    logging.info("filtering")
    n = 0
    vocab = []
    for word, freq in count.items():
        if spell.check(word) or freq > args.min_freq:
            vocab.append(word)
            n += 1
        else:
            logging.debug("mispell: %s (%d)" % (word, freq))
        if n >= args.size:
            break

    logging.info("writing to file: %s" % args.vocab_file)
    with open(args.vocab_file, "w") as f:
        for word in sorted(vocab, key=collator.getSortKey):
            f.write("%s\n" % word)
