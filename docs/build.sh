#!/usr/bin/env bash

if [[ ! -f "../pyproject.toml" ]]; then
  echo "Please run from the docs directory."
  exit 1
fi

TARGET=singlehtml

python3 -m venv --clear .docs_venv

echo "Installing dependencies"
.docs_venv/bin/pip install sphinx myst_parser sphinx-rtd-theme

echo "Installing python bindings"
.docs_venv/bin/pip install --force --no-cache ..

echo "Building the website"
.docs_venv/bin/sphinx-build -M ${TARGET} . _build
