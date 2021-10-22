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


## Usage

:warning: Remember SRILM must be installed and set to `$PATH` beforehand.

```bash
$ git clone https://github.com/falabrasil/lm-br.git
$ cd lm-br
$ ./run.sh
```


## Docker :whale:

:warning: We won't be pushing this image to dockerhub because SRILM's license 
might now allow it. Make sure to download SRILM yourself and place the
`*.tar.gz` file under this repo's dir.

To build the Debian-slim-based image and check for SRILM's version, do the 
following:

```bash
$ cd lm-br  # from git clone
$ docker build -t falabrasil/lm-br:latest -f docker/Dockefile .
$ docker run --rm -it falabrasil/lm-br:latest bash
$ ngram -version
```

The output should be as follows:

```text
SRILM release 1.7.3 (with third-party contributions)
Built with GCC 11.1.0
and options -g -O3 

Program version @(#)$Id: ngram-count.cc,v 1.81 2019/09/09 23:13:13 stolcke Exp $

Support for compressed files is included.
Using OpenMP version 201511.

This software is subject to the SRILM Community Research License Version
1.0 (the "License"); you may not use this software except in compliance
with the License.  A copy of the License is included in the SRILM root
directory in the "License" file.  Software distributed under the License
is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
express or implied.  See the License for the specific language governing
rights and limitations under the License.

This software is Copyright (c) 1995-2019 SRI International.  All rights
reserved.

Portions of this software are
Copyright (c) 2002-2005 Jeff Bilmes
Copyright (c) 2009-2013 Tanel Alumae
Copyright (c) 2011-2019 Andreas Stolcke
Copyright (c) 2012-2019 Microsoft Corp.

SRILM also includes open-source software as listed in the
ACKNOWLEDGEMENTS file in the SRILM root directory.

If this software was obtained under a commercial license agreement with
SRI then the provisions therein govern the use of the software and the
above notice does not apply.
```


## Notes :memo:

- Beware you'll probably need at least 32 GB of RAM on your machine. Sparing
  some swap space is also advised.
- You'll also need docker :whale: installed and running for G2P.
- Evaluation is performed on the Portuguese portion of
  [Mozilla's Common Voice](https://commonvoice.mozilla.org/) dataset.
- On Debian-based OS, `pkg-config`, `libaspell-dev`, and `libicu-dev` are
  dependencies to some Python modules. Check the Dockerfile to see the packages
  downloaded via `apt-get`.


[![FalaBrasil](https://gitlab.com/falabrasil/avatars/-/raw/main/logo_fb_git_footer.png)](https://ufpafalabrasil.gitlab.io/ "Visite o site do Grupo FalaBrasil") [![UFPA](https://gitlab.com/falabrasil/avatars/-/raw/main/logo_ufpa_git_footer.png)](https://portal.ufpa.br/ "Visite o site da UFPA")

__Grupo FalaBrasil (2021)__ - https://ufpafalabrasil.gitlab.io/    
__Universidade Federal do Pará (UFPA)__ - https://portal.ufpa.br/     
Cassio Batista - https://cassota.gitlab.io/
