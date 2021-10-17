#!/usr/bin/env python3
#
# counts words from a corpus text file and
# generates a sorted frequency list
#
# author: oct 2021
# cassio batista - https://cassota.gitlab.io

import sys
import argparse
import logging

from tqdm import tqdm


logging.basicConfig(
        format='[%(asctime)s] [%(module)s] %(levelname)-8s %(message)s',
        level=logging.INFO)

parser = argparse.ArgumentParser(
        description="builds a frequency list of words from a corpus")
parser.add_argument("corpus_file", help="input file")
parser.add_argument("word_freq_file", help="output file")

args = parser.parse_args()


if __name__ == "__main__":

    logging.warning("** THIS SCRIPT CONSUMES A LOT OF MEMORY **")
    logging.warning("you better have at least 32 GB of RAM for a 10 GB file")

    # NOTE this splits the file on linebreaks instead of all whitespaces
    # because segmenting at the word level takes a TON more RAM
    logging.info("loading file (all at once into RAM): %s" % args.corpus_file)
    with open(args.corpus_file) as f:
        corpus = f.read().split("\n")

    logging.info("counting")
    count = {}
    for sent in tqdm(corpus):
        for word in sent.split():
            if word in count:
                count[word] += 1
            else:
                count[word] = 1

    logging.info("writing file: %s" % args.word_freq_file)
    with open(args.word_freq_file, "w") as f:
        for i, (word, freq) in enumerate(
                sorted(count.items(), key=lambda x: x[1], reverse=True)
            ):
            f.write("%s\t%d\n" % (word, freq))
        logging.info("done! frequency list contains %d words" % (i + 1))
