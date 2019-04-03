FROM alpine:3.8
RUN apk add --no-cache bash nodejs npm
LABEL "com.github.actions.name"="markdown-link-check"
LABEL "com.github.actions.description"="Check if all links are valid in markdown files."
LABEL "com.github.actions.icon"="link"
LABEL "com.github.actions.color"="green"
LABEL "repository"="https://github.com/gaurav-nelson/github-action-markdown-link-check.git"
LABEL "homepage"="https://github.com/gaurav-nelson/github-action-markdown-link-check"
LABEL "maintainer"="Gaurav Nelson"
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
