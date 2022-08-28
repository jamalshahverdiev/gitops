FROM bash:5.1
RUN apk add git jq curl coreutils gettext
ENV GH_USER alekum
ENV GH_PAT_TOKEN ghtokenvalue
ENV ARGO_USER salam
ENV ARGO_PASS hihi
COPY libs libs
COPY templates templates 
COPY gh_main.sh gh_main.sh
ENTRYPOINT ["./gh_main.sh"] 
CMD ["$GH_USER", "$GH_PAT_TOKEN", "$ARGO_USER", "$ARGO_PASS"]
