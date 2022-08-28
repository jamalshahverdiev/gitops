#!/usr/bin/env bash

REPO='argocd'
ORG='orgname'
GH_ORG_LINK="github.com/orgname/${REPO}"
GH_USER_EMAIL="orgnamebot@orgname.com"
GH_USER_FULLNAME='Orgname Bot'
FOLDER='''
frontapp1
frontapp2
'''
ARGO_JSON_TEMP_FILE='templates/argo_api.json'
ARGOCD_SERVER='argocd-server.argocd'
REGEX_STRING='.argocd-source'