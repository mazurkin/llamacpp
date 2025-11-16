SHELL := /bin/bash
ROOT  := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

CONDA_ENV_NAME = llamacpp

# -----------------------------------------------------------------------------
# notebook
# -----------------------------------------------------------------------------

.DEFAULT_GOAL = run

# -----------------------------------------------------------------------------
# conda environment
# -----------------------------------------------------------------------------

.PHONY: env-init
env-init:
	@conda create --yes --name "$(CONDA_ENV_NAME)" \
		python=3.12.12 \
		nvidia::cuda-toolkit=12.6.3 \
		conda-forge::cudnn=9.3.0.75 \
		conda-forge::cmake=4.1.2 \
		conda-forge::poetry=2.2.1

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

.PHONY: run
run: export PATH="$(ROOT)/llamacpp/build/bin:${PATH}"
run:
	@conda run --no-capture-output --live-stream --name "$(CONDA_ENV_NAME)" --cwd "$(ROOT)/llamacpp/build/bin" \
		bash

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
build-release:
	@conda run --no-capture-output --live-stream --name "$(CONDA_ENV_NAME)" --cwd "$(ROOT)/llamacpp/build" \
		cmake --build . --config Release -j 1

.PHONY: build
build: build-clean build-init build-configure build-release

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
