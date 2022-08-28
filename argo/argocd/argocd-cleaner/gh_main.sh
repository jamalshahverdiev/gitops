#!/usr/bin/env bash

if [[ $# -lt 4 ]]; then echo "Usage: ./$(basename $0) git_user git_pat_token argo_user argo_pass"; exit 14; fi
git_user=$GH_USER
git_pat_token=$GH_PAT_TOKEN
export argo_user=$ARGO_USER
export argo_pass=$ARGO_PASS

. ./libs/variables.sh
. ./libs/functions.sh

github_argo_repo_scan ${git_user} ${git_pat_token}