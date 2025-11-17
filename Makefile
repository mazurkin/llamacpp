SHELL := /bin/bash
ROOT  := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

CONDA_ENV_NAME = llamacpp

# -----------------------------------------------------------------------------
# default
# -----------------------------------------------------------------------------

.DEFAULT_GOAL = shell

# -----------------------------------------------------------------------------
# conda environment
# -----------------------------------------------------------------------------

.PHONY: env-init
env-init:
	@conda create --yes --copy --name "$(CONDA_ENV_NAME)" \
		conda-forge::python=3.12.12 \
		conda-forge::poetry=2.2.1 \
		conda-forge::cudnn=9.3.0.75 \
		conda-forge::cmake=4.1.2 \
		conda-forge::gcc=12.4.0 \
		conda-forge::libgcc-ng=15.2.0 \
		conda-forge::libgcc=15.2.0 \
		conda-forge::libstdcxx-ng=15.2.0 \
		nvidia::cuda-toolkit=12.6.3

.PHONY: env-create
env-create:
	@conda run --no-capture-output --live-stream --name "$(CONDA_ENV_NAME)" \
		poetry install --no-root --no-directory

.PHONY: env-update
env-update:
	@conda run --no-capture-output --live-stream --name "$(CONDA_ENV_NAME)" \
		poetry update

.PHONY: env-list
env-list:
	@conda run --no-capture-output --live-stream --name "$(CONDA_ENV_NAME)" \
		poetry show

.PHONY: env-remove
env-remove:
	@conda env remove --yes --name "$(CONDA_ENV_NAME)"

.PHONY: env-shell
env-shell:
	@conda run --no-capture-output --live-stream --name "$(CONDA_ENV_NAME)" \
		bash

.PHONY: env-info
env-info:
	@conda run --no-capture-output --live-stream --name "$(CONDA_ENV_NAME)" \
		conda info

# -----------------------------------------------------------------------------
# run
# -----------------------------------------------------------------------------

.PHONY: shell
shell: export PATH := $(ROOT)/llamacpp/build/bin:$(PATH)
shell:
	@conda run --no-capture-output --live-stream --name "$(CONDA_ENV_NAME)" --cwd "$(ROOT)/llamacpp/build/bin" \
		 bash --rcfile "$(ROOT)/etc/bashrc"

.PHONY: server
server: export PATH := $(ROOT)/llamacpp/build/bin:$(PATH)
server:
	@conda run --no-capture-output --live-stream --name "$(CONDA_ENV_NAME)" --cwd "$(ROOT)/llamacpp/build/bin" \
		llama-server -hf ggml-org/gemma-3-1b-it-GGUF

# -----------------------------------------------------------------------------
# build
# -----------------------------------------------------------------------------

.PHONY: build-clean
build-clean:
	@rm -rf "$(ROOT)/llamacpp/build"

.PHONY: build-init
build-init:
	@mkdir -p "$(ROOT)/llamacpp/build"

.PHONY: build-configure
build-configure:
	@conda run --no-capture-output --live-stream --name "$(CONDA_ENV_NAME)" --cwd "$(ROOT)/llamacpp/build" \
		cmake .. -DGGML_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES=89

.PHONY: build-release
build-release: export LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH
build-release:
	@conda run --no-capture-output --live-stream --name "$(CONDA_ENV_NAME)" --cwd "$(ROOT)/llamacpp/build" \
		cmake --build . --config Release -j 8

.PHONY: build
build: build-clean build-init build-configure build-release

# -----------------------------------------------------------------------------
# clean
# -----------------------------------------------------------------------------

.PHONY: wipe
wipe: build-clean env-remove

# -----------------------------------------------------------------------------
# nvidia tools
# -----------------------------------------------------------------------------

.PHONY: nvidia-cap
nvidia-cap:
	@conda run --no-capture-output --live-stream --name "$(CONDA_ENV_NAME)" \
		nvidia-smi --query-gpu=compute_cap --format=csv

.PHONY: nvidia-smi
nvidia-smi:
	@conda run --no-capture-output --live-stream --name "$(CONDA_ENV_NAME)" \
		nvidia-smi
