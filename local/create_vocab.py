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

logging.basicConfig(
        format='[%(asctime)s] [%(module)s] %(levelname)-8s %(message)s',
        level=logging.INFO)

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
    vocab = []
    for word, freq in count.items():
        if spell.check(word) or freq > args.min_freq:
            vocab.append(word)
        else:
            logging.debug("misspell: %s (%d)" % (word, freq))
        if len(vocab) >= args.size:
            break

    logging.info("writing to file: %s" % args.vocab_file)
    with open(args.vocab_file, "w") as f:
        for i, word in enumerate(sorted(vocab, key=collator.getSortKey)):
            f.write("%s\n" % word)
        logging.info("done! vocabulary contains %d words" % (i + 1))
