# Language Model Training :brazil:

:fox_face: Pre-trained models on GitLab (LFS):
https://gitlab.com/fb-resources/lm-br

Scripts to train n-gram language models in ARPA format, currently using only
[SRILM](http://www.speech.sri.com/projects/srilm/). Based on Kaldi scripts
for LibriSpeech ([local/lm/train_lm.sh](https://github.com/kaldi-asr/kaldi/blob/master/egs/librispeech/s5/local/lm/train_lm.sh)).

It also generates a phonetic dicionary from a pre-specified list of words 
(top-N most frequent, estimated from OSCAR) using 
[FalaBrasil's G2P](https://hub.docker.com/r/falabrasil/g2p).

A demonstration is performed over five files of the first version (2019) of the
[OSCAR corpus](https://oscar-corpus.com/post/oscar-2019/#downloading-oscar).
Raw data sums up to 9.5 GB while after normalisation clean data is 7.5 GB.


## Notes

- Beware you'll probably need at least 32 GB of RAM on your machine.
- You'll also need docker :whale: installed and running for G2P.
- Evaluation is performed on the Portuguese portion of
[Mozilla's Common Voice](https://commonvoice.mozilla.org/) dataset.
- On Debian-based OS, `libaspell-dev` and `libicu-dev` are dependencies to some
  Python modules.


## Usage

:warning: Remember SRILM must be installed and set to `$PATH` beforehand.

```bash
$ git clone https://github.com/falabrasil/lm-br.git
$ cd lm-br
$ ./run.sh
```


[![FalaBrasil](https://gitlab.com/falabrasil/avatars/-/raw/main/logo_fb_git_footer.png)](https://ufpafalabrasil.gitlab.io/ "Visite o site do Grupo FalaBrasil") [![UFPA](https://gitlab.com/falabrasil/avatars/-/raw/main/logo_ufpa_git_footer.png)](https://portal.ufpa.br/ "Visite o site da UFPA")

__Grupo FalaBrasil (2021)__ - https://ufpafalabrasil.gitlab.io/    
__Universidade Federal do Pará (UFPA)__ - https://portal.ufpa.br/     
Cassio Batista - https://cassota.gitlab.io/
