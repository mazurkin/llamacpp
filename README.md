# llama.cpp

build environment for linux with CUDA support

tested on Ubuntu 22.04 with CUDA 13.0

## prerequisites

install [conda](https://www.anaconda.com/docs/getting-started/miniconda/install)

## clone

git clone --recurse-submodules git@github.com:mazurkin/llamacpp.git

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

## GGUF

```shell
# Convert to GGUF (F16 - full precision)
bin/convert_hf_to_gguf.sh \
    target/model \
    --outfile target/model.gguf \
    --outtype f16

# Or quantize to smaller size (Q4_K_M is good balance)
bin/convert_hf_to_gguf.sh \
    target/model \
    --outfile target/model-q4.gguf \
    --outtype q4_k_m
```

```text
Type	Size (8B model)	Quality	    Speed
F16	    ~16 GB	        Best	    Slowest
Q8_0	~8 GB	        Excellent	Fast
Q5_K_M	~5.5 GB	        Very Good	Faster
Q4_K_M	~4.5 GB	        Good	    Fast
Q4_0	~4 GB	        Acceptable	Fastest
```

```shell
llama.cpp/llama-cli \
    -m target/model-q4.gguf \
    -p "Question: How Are You?\nAnswer:" \
    -n 256 \
    --temp 0.7 \
    --repeat-penalty 1.1

llama.cpp/llama-server \
    -m target/model-q4.gguf \
    --host 0.0.0.0 \
    --port 8080
```
