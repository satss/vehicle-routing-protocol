#!/bin/bash

setup_python_environment() {
  uv venv --seed --allow-existing
  uv sync --all-groups --all-packages
}

install_pre_commit_hook() {
  uv run pre-commit install
}

setup_python_environment
install_pre_commit_hook
