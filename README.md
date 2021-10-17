# SRILM 🇧🇷

Scripts to train n-gram language models using 
[SRILM](http://www.speech.sri.com/projects/srilm/). Based on Kaldi scripts
for LibriSpeech ([local/lm/train_lm.sh](https://github.com/kaldi-asr/kaldi/blob/master/egs/librispeech/s5/local/lm/train_lm.sh))

It also generates a
phonetic dicionary of a pre-specified number of words (top-N most frequent,
estimated from OSCAR) using [FalaBrasil's G2P](https://hub.docker.com/r/falabrasil/g2p).

A demonstration is performed over five files of the first version (2019) of the
[OSCAR corpus](https://oscar-corpus.com/post/oscar-2019/#downloading-oscar).
Raw data sums up to 9.5 GB while after normalisation clean data is 7.5 GB.

:warning: Beware you'll probably need at least 32 GB of RAM on your machine.

:warning: You'll also need docker :whale: installed and running for G2P.


## Usage

Remember SRILM must be installed and set to `$PATH` beforehand.

```bash
$ git clone https://github.com/falabrasil/srilm-br.git
$ cd srilm-br
$ ./run.sh
```


[![FalaBrasil](https://gitlab.com/falabrasil/avatars/-/raw/main/logo_fb_git_footer.png)](https://ufpafalabrasil.gitlab.io/ "Visite o site do Grupo FalaBrasil") [![UFPA](https://gitlab.com/falabrasil/avatars/-/raw/main/logo_ufpa_git_footer.png)](https://portal.ufpa.br/ "Visite o site da UFPA")

__Grupo FalaBrasil (2021)__ - https://ufpafalabrasil.gitlab.io/    
__Universidade Federal do Pará (UFPA)__ - https://portal.ufpa.br/     
Cassio Batista - https://cassota.gitlab.io/
