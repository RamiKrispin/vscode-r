#!/usr/bin/env bash

apt-get update && apt-get install -y --no-install-recommends libxml2-dev

Rscript .devcontainer/dependencies.R