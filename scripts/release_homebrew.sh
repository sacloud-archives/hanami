#!/bin/bash

VERSION=`git log --merges --oneline | perl -ne 'if(m/^.+Merge pull request \#[0-9]+ from .+\/bump-version-([0-9\.]+)/){print $1;exit}'`
SHA256_SRC_DARWIN=`openssl dgst -sha256 bin/hanami_darwin-amd64.zip | awk '{print $2}'`
SHA256_SRC_LINUX=`openssl dgst -sha256 bin/hanami_linux-amd64.zip | awk '{print $2}'`
SHA256_BASH_COMP=`openssl dgst -sha256 contrib/completion/bash/hanami | awk '{print $2}'`

# clone
git clone --depth=50 --branch=master https://github.com/sacloud/homebrew-hanami.git homebrew-hanami
cd homebrew-hanami

# check version
CURRENT_VERSION=`git log --oneline | perl -ne 'if(/^.+ v([0-9\.]+)/){print $1;exit}'`
if [ "$CURRENT_VERSION" = "$VERSION" ] ; then
    echo "homebrew-hanami v$VERSION is already released."
    exit 0
fi

cat << EOL > hanami.rb
class Usacloud < Formula

  hanami_version = "${VERSION}"
  sha256_src_darwin = "${SHA256_SRC_DARWIN}"
  sha256_src_linux = "${SHA256_SRC_LINUX}"
  sha256_bash_completion = "${SHA256_BASH_COMP}"

  desc "Unofficial 'sacloud' - CLI client of the SakuraCloud"
  homepage "https://github.com/sacloud/hanami"
  head "https://github.com/sacloud/hanami.git"
  version hanami_version

  if OS.mac?
    url "https://github.com/sacloud/hanami/releases/download/v#{hanami_version}/hanami_darwin-amd64.zip"
    sha256 sha256_src_darwin
  else
    url "https://github.com/sacloud/hanami/releases/download/v#{hanami_version}/hanami_linux-amd64.zip"
    sha256 sha256_src_linux
  end

  option "without-completions", "Disable bash completions"
  resource "bash_completion" do
    url "https://releases.hanami.jp/hanami/contrib/completion/bash/hanami"
    sha256 sha256_bash_completion
  end

  def install
    bin.install "hanami"
    if build.with? "completions"
      resource("bash_completion").stage {
        bash_completion.install "hanami"
      }
    end

  end

  test do
    assert_match "SAKURACLOUD_ACCESS_TOKEN", shell_output("hanami --help")
  end
end
EOL

git config --global push.default matching
git config user.email 'sacloud.users@gmail.com'
git config user.name 'sacloud-bot'
git add .
git commit -m "v${VERSION}"

echo "Push ${VERSION} to github.com/sacloud/homebrew-hanami.git"
git push -u "https://${GITHUB_TOKEN}@github.com/sacloud/homebrew-hanami.git"

echo "Cleanup tag v${VERSION} on github.com/sacloud/homebrew-hanami.git"
git push -u "https://${GITHUB_TOKEN}@github.com/sacloud/homebrew-hanami.git" :v${VERSION}

echo "Tagging v${VERSION} on github.com/sacloud/homebrew-hanami.git"
git tag v${VERSION} 2>&1 >/dev/null
git push -u "https://${GITHUB_TOKEN}@github.com/sacloud/homebrew-hanami.git" v${VERSION}
exit 0
