#!/usr/bin/env python3
#
# creates a vocabulary file (list of words) filtered 
# by aspell combined with a frequency-based threshold
#
# author: oct 2021
# cassio batista - https://cassota.gitlab.io

import sys
import re
import locale
import argparse
import logging
import gzip

import unidecode
import aspell
import icu

ALLOW_LIST = [
    "à",
    "www",
    "bbb",
    "ddd",
]

logging.basicConfig(
        format='[%(asctime)s] [%(module)s] %(levelname)-8s %(message)s',
        level=logging.DEBUG)

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

    locale.setlocale(locale.LC_ALL, 'pt_BR.UTF-8')
    spell = aspell.Speller( ('lang', 'pt_BR'), ('ignore-case', 'true') )
    collator = icu.Collator.createInstance(icu.Locale('pt_BR.UTF-8'))

    logging.info("loading file: %s" % args.count_file)
    count = {}
    with gzip.open(args.count_file, "rb") as f:
        for line in f:
            word, freq = line.decode().split()
            count[word] = int(freq)

    logging.info("filtering")
    vocab = []
    bacov = set()  # gambiarra: keep track of the unidecoded
    #for word, freq in dict(sorted(count.items())).items():
    for word, freq in count.items():
        # aspell validates or frequency is higher to bypass such validation
        # TODO these rules should be added to oscar normaliser right away
        if spell.check(word) or freq > args.min_freq:
            if word in ALLOW_LIST:
                vocab.append(word)
                continue
            # starts or ends with cedilha "ç" or grave-accented a "à"
            match = re.match(r"^ç|[çà]$", word)
            if match:
                logging.debug("Misspell: %s (%d)" % (word, freq))
                continue
            # triple repeat, e.g. aaa, ááá, áaá, aàã
            match = re.findall(r"(.)\1{2,}", unidecode.unidecode(word))
            if match:
                logging.debug("mIsspell: %s (%d)" % (word, freq))
                continue
            # long words
            if len(word) > 23:
                logging.debug("miSspell: %s (%d)" % (word, freq))
                continue
            # double+ diacritics don't exist in portuguese
            for subword in word.split("-"):
                if sum(map(subword.count, list("àáéíóúâêô"))) > 1:
                    logging.debug("misSpell: %s (%d)" % (word, freq))
                    continue
            # NOTE this is too important to be part of the vocab clean. it
            #      should be a part of the normaliser instead. a backup of
            #      the log file was saved to be looked upon later - Cassio
            ## diacritic typo
            #if unidecode.unidecode(word) in bacov:
            #    logging.debug("missPell: %s (%d)" % (word, freq))
            #    continue
            ## success!
            vocab.append(word)
            bacov.add(unidecode.unidecode(word))
        else:
            logging.error("misspell: %s (%d)" % (word, freq))
        if len(vocab) >= args.size:
            break

    logging.info("writing to file: %s" % args.vocab_file)
    with gzip.open(args.vocab_file, "wb") as f:
        for i, word in enumerate(sorted(vocab, key=collator.getSortKey)):
            f.write(b"%s\n" % word.encode())
        logging.info("done! vocabulary contains %d words" % (i + 1))
