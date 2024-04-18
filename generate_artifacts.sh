#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

python -m build --sdist --wheel

rm -rf /streamlit_oauth_artifacts/*

mkdir -p /streamlit_oauth_artifacts/streamlit_oauth/frontend/dist
cp -r streamlit_oauth/frontend/dist /streamlit_oauth_artifacts/streamlit_oauth/frontend/dist
mv build/ /streamlit_oauth_artifacts/
mv dist/ /streamlit_oauth_artifacts/
mv streamlit_oauth.egg-info/ /streamlit_oauth_artifacts/
