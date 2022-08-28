#!/usr/bin/env bash

function cleanUP {
  rm -rf ${REPO} 
}

initialize_argo_token() {
    cat $ARGO_JSON_TEMP_FILE | envsubst > result.json
    ARGOCD_TOKEN=$(curl -s http://${ARGOCD_SERVER}/api/v1/session -d @result.json | jq -r '.token')
    rm -rf result.json
}
get_argocd_appset_apps() {
    if [[ $# -lt 1 ]]; then echo "Usage: ./$(basename $0) appset_name"; fi
    appset_name=$1
    argocd_apps_obj=$(curl -s http://${ARGOCD_SERVER}/api/v1/applications \
        -H "Authorization: Bearer $ARGOCD_TOKEN" | jq '.items[]|select(.metadata.ownerReferences).metadata')
    app_names_of_appset=$(echo ${argocd_apps_obj} | jq -r 'select(.ownerReferences[].name=="'$appset_name'").name')
}

github_argo_repo_scan() {
    if [[ $# -lt 2 ]]; then echo "Usage: ./$(basename $0) GH_USER GH_PAT"; exit 12; fi
    GH_USER=$1
    GH_PAT=$2
    initialize_argo_token
    git clone "https://${GH_USER}:${GH_PAT}@${GH_ORG_LINK}" && pushd ${REPO} 
    git config --global user.email "${GH_USER_EMAIL}"
    git config --global user.name "${GH_USER_FULLNAME}"

    for fldr_path in $FOLDER; do 
        echo "---------------- Scanning folder in path: $fldr_path ----------------"
        pushd $fldr_path
        ARGO_HIDDEN_FILES=$(curl -s -H "Authorization: Bearer ${GH_PAT}" \
            -H  "Content-Type:application/json" \
            "https://api.github.com/repos/${ORG}/${REPO}/contents/${fldr_path}" \
            | jq -r '.[].name' | grep ^${REGEX_STRING})
        get_argocd_appset_apps $fldr_path
        for file in $ARGO_HIDDEN_FILES; do
            parsed_file_name=$(echo $file | sed 's/.argocd-source-//g;s/.yaml//g')
            if [[ $app_names_of_appset != *"$parsed_file_name"* ]]; then
                echo "File with name ${fldr_path}/$file will be deleted."
                git rm -f $file
                git commit -m "Delete ${fldr_path}/$file"
            fi
        done
        popd 
    done
    git push origin main
    popd && trap cleanUP SIGINT SIGTERM SIGTSTP EXIT
}