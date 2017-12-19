#!/bin/bash

VERSION=`git log --merges --oneline | perl -ne 'if(m/^.+Merge pull request \#[0-9]+ from .+\/bump-version-([0-9\.]+)/){print $1;exit}'`

# clone
git clone --depth=50 --branch=master https://github.com/sacloud/releases-hanami.git releases-hanami
cd releases-hanami
git fetch origin

# check version
CURRENT_VERSION=`git tag -l --sort=-v:refname | perl -ne 'if(/^([0-9\.]+)$/){print $1;exit}'`
if [ "$CURRENT_VERSION" = "$VERSION" ] ; then
    echo "sacloud/releases-hanami v$VERSION is already released."
    exit 0
fi

# build website static contents
rm -rf bin/
cp -r ../bin ./

rm -rf contrib/
cp -r ../contrib ./

rm -rf repos/
cp -r ../repos ./

cat << EOL > status.html
OK(current version: v${VERSION})
EOL

# commit and push to github.com
git config --global push.default matching
git config user.email 'sacloud.users@gmail.com'
git config user.name 'sacloud-bot'
git add .
git commit -m "v${VERSION}"
git tag "${VERSION}"

echo "Push ${VERSION} to github.com/sacloud/releases-hanami.git"
git push -u "https://${GITHUB_TOKEN}@github.com/sacloud/releases-hanami.git"

echo "Cleanup tag ${VERSION} on github.com/sacloud/releases-hanami.git"
git push -u "https://${GITHUB_TOKEN}@github.com/sacloud/releases-hanami.git" :${VERSION}

echo "Tagging ${VERSION} on github.com/sacloud/releases-hanami.git"
git push -u "https://${GITHUB_TOKEN}@github.com/sacloud/releases-hanami.git" ${VERSION}
exit 0
