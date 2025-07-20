# ExLlama batch quantization docker

## Overview

This project provides a Docker based environment for creating ExLlama models (both V2 and V3 versions). It includes tools quantization, with support for batch processing and measurement reuse. It's based on tabbyapi docker, which you may already have.

## Features

- Pre-configured Docker environment with ExLlama V2 and V3 repositories
- Batch quantization capabilities
- Reuse measurements.json for efficient quantization
- Ready-to-use model conversion pipeline
- Minimal base image with essential utilities

## Directory Structure

```pre
├── Dockerfile          # Base image with ExLlama setup
├── docker-compose.yml  # Container orchestration
├── batch_quant_exllama.sh  # Batch quantization script
├── models/             # Directory for storing model files
├── exl2tmp/            # Temporary directory for processing
```

## Usage

### 1. Batch Quantization

Example usage (v2 or v3):

```bash
./batch_quant_exllama.sh 2 Qwen2.5-0.5B-Instruct,4.25 Qwen2.5-0.5B-Instruct,5.0 Qwen2.5-0.5B-Instruct,6.5
./batch_quant_exllama.sh 3 Qwen2.5-0.5B-Instruct,4.0 Qwen2.5-0.5B-Instruct,3.5
```

## Docker Configuration

The container:

- Requires the nvidia container toolkit correctly installed and setup.
- Requires "docker compose" on the command line
- Based on the latest tabbyAPI docker image
- Pre-built docker image at: ghcr.io/matatonic/exllama-batch-quant-docker
- Installs git, vim, and bash utilities
- Clones official ExLlama v2 & v3 repositories
- Installs Python dependencies (datasets library)
- Sets up for GPU acceleration with CUDA support

## Development Notes

- It's not ideal, but it's simple and works for me.
- Doesn't do much error checking, for example if measurement fails, it may try again and again
- The environment variable `CLI_ARGS` controls the default command
- Both ExLlama versions are available in the container for cross-version testing
- The bash script (batch_quant_exllama.sh) runs "docker compose up" with custom command lines for each model
- With slight modification can be used to automatically upload to huggingface.

## Related Projects

- https://github.com/turboderp-org/exllamav2
- https://github.com/turboderp-org/exllamav3
- https://github.com/theroyallab/tabbyAPI
