# llama.cpp

build environment for linux with CUDA support

tested on Ubuntu 22.04 with CUDA 13.0

## prerequisites

install [conda](https://www.anaconda.com/docs/getting-started/miniconda/install)

## prepare

```shell
# install the conda environment with CUDA, cmake and all the dependencies
$ make env-init
$ make env-poetry
$ make env-requirements
```

## build

```shell
# check nvidia capabilities (mine is 8.9)
# replace `-DCMAKE_CUDA_ARCHITECTURES=89` in the Makefile with your version if required
$ make nvidia-cap
```

```shell
# build llama.cpp executables in `llamacpp/build/bin`
$ make build
```

## run

```shell
# run BASH shell in the output folder
$ make shell

# run llama-server
$ llama-server -hf ggml-org/gemma-3-1b-it-GGUF
```
