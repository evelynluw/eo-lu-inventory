#!/bin/bash
# Purpose: Install requirements for python
# Author: Evelyn Lu 
# --------------------------------------

# Setting up the environment
echo "Updating pip"
pip install -U pip
echo "Activating virtual environment..."
source .venv/bin/activate
echo "Updating requirements..."
pip install -r required_packages/requirements.txt

# Remove existing data
# echo "Cleaning up existing data folder..."
# rm -rf data
# echo "Re-making data folder..."
# mkdir data
# mkdir -p data/raw/

# Extracting Data