# llama.cpp

tested on Ubuntu 22.04

## prepare

```shell
# install the conda environment with CUDA, cmake and all the dependencies
$ make env-init
$ make env-create
```

## build

```shell
# check nvidia capabilities (mine is 8.9)
$ make nvidia-cap
```

```shell
# build llama.cpp executables
$ make build
```

## run

```shell
# run BASH shell in the output folder
$ make run
```
