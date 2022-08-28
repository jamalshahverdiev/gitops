# Clean ArgoCD created `.argocd-source-*.yaml` files from [argocd](https://github.com/orgname/argocd) repository 

#### Code structure looks like as the following

![`Code Structure`](images/code_struct.png)


- `gh_main.sh` - file the main entrypoint script inside of docker container with predefined environment variables. Script requires `4` arguments `GH_USER`, `GH_PAT_TOKEN`, `ARGO_USER` and `ARGO_PASS` to communicate `GitHub` and `ArgoCD` API's. These variables comes to script like as argument from environment variables. To execute the `github_argo_repo_scan` with needed arguments, `gh_main.sh` script must load variables and functions from `libs` folder.
- `libs` - Folder contains functions and variables files 
    - `functions.sh` - All functions defined here
    - `variables.sh` - All variables defined here
- `templates` - Folder contain templates needed for code files
    - `argo_api.json` - Json template file to create form to authenticate with `ArgoCD` API
- `manifests` - Folder contains Kubernetes manifests to apply to the cluster
    - `secret.yaml` - File contains credentials as variables for `GitHub` and `ArgoCD`
    - `argocleaner-cronjob.yaml` - Cronjob file which will pull docker container from `GAR` path `us-central1-docker.pkg.dev/org-images/org/argocdcleaner` with some version tag.
- `Dockerfile` - File contains scenario to create container and push it to `Google Artifact Registry`

#### To create new image from code file we can do the following steps

```bash
$ docker build -t container.registry.domain/with/path/:containerversion .
$ docker push container.registry.domain/with/path/:containerversion 
```

#### To test image locally we can execute the following command

```bash
$ docker container run \
    -e GH_USER='SOME_GITHUB_USER' \
    -e GH_PAT_TOKEN='some_git_pat_token' \
    -e ARGO_USER='SOME_ARGO_USER' \
    -e ARGO_PASS='SOME_ARGO_PASS' \
    -itd --name=argocdcleaner \
    container.registry.domain/with/path/:containerversion
```

#### Logs of CronJob must look as the following in case of nothing to do

```bash
$ job_pod=$(kubectl get pods | grep argocleaner | tail -n1 | awk '{ print $1 }') 
$ kubectl logs $job_pod                                              
Cloning into 'argocd'...
/argocd /
---------------- Scanning folder in path: frontapp1 ----------------
/argocd/frontapp1 /argocd /
/argocd /
---------------- Scanning folder in path: frontapp2 ----------------
/argocd/frontapp2 /argocd /
/argocd /
Everything up-to-date
/
```