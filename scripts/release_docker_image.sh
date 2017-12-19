#!/bin/bash

VERSION=`git log --merges --oneline | perl -ne 'if(m/^.+Merge pull request \#[0-9]+ from .+\/bump-version-([0-9\.]+)/){print $1;exit}'`

# clone
git clone --depth=50 --branch=master https://github.com/sacloud/hanami-docker.git hanami-docker
cd hanami-docker
git fetch origin

# check version
CURRENT_VERSION=`git tag -l --sort=-v:refname | perl -ne 'if(/^([0-9\.]+)$/){print $1;exit}'`
if [ "$CURRENT_VERSION" = "$VERSION" ] ; then
    echo "hanami-docker v$VERSION is already released."
    exit 0
fi

cat << EOL > Dockerfile
FROM alpine:3.7
MAINTAINER Kazumichi Yamamoto <yamamoto.febc@gmail.com>
LABEL MAINTAINER 'Kazumichi Yamamoto <yamamoto.febc@gmail.com>'

LABEL io.whalebrew.config.environment '["SAKURACLOUD_ACCESS_TOKEN", "SAKURACLOUD_ACCESS_TOKEN_SECRET" , "SAKURACLOUD_TRACE_MODE"]'

RUN set -x && apk add --no-cache --update zip ca-certificates

ADD https://github.com/sacloud/hanami/releases/download/v${VERSION}/hanami_linux-amd64.zip ./
RUN unzip hanami_linux-amd64.zip -d /bin; rm -f hanami_linux-amd64.zip

VOLUME ["/workdir"]
WORKDIR /workdir

ENTRYPOINT ["/bin/hanami"]
CMD ["--help"]
EOL

git config --global push.default matching
git config user.email 'sacloud.users@gmail.com'
git config user.name 'sacloud-bot'
git commit -am "v${VERSION}"
git tag "${VERSION}"

echo "Push ${VERSION} to github.com/sacloud/hanami-docker.git"
git push --quiet -u "https://${GITHUB_TOKEN}@github.com/sacloud/hanami-docker.git" >& /dev/null

echo "Cleanup tag ${VERSION} on github.com/sacloud/hanami-docker.git"
git push --quiet -u "https://${GITHUB_TOKEN}@github.com/sacloud/hanami-docker.git" :${VERSION} >& /dev/null

echo "Tagging ${VERSION} on github.com/sacloud/hanami-docker.git"
git push --quiet -u "https://${GITHUB_TOKEN}@github.com/sacloud/hanami-docker.git" ${VERSION} >& /dev/null
exit 0
