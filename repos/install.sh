#!/bin/bash

set -e
sudo -k

if [ "$(uname)" == 'Darwin' ]; then
  OS='Mac'
  if type brew >/dev/null 2>&1; then
    install_by_brew
    exit 0
  else
    echo "To install hanami, you need 'brew' command"
    exit 1
  fi
elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
  OS='Linux'
  if type yum >/dev/null 2>&1; then
    install_by_yum
    exit 0
  elif type apt > /dev/null 2>&1; then
    install_by_apt
    exit 0
  elif type brew > /dev/null 2>&1; then
    install_by_brew
    exit 0
  fi

  echo "To install hanami, you need 'apt' or 'yum' or 'brew' command"
  exit 1

else
  echo "Your platform ($(uname -a)) is not supported."
  exit 1
fi

exit 0

install_by_brew {
  set -x
  brew tap sacloud/hanami
  brew install sacloud/hanami
}

install_by_yum {
  sudo sh <<'SCRIPT'
    set -x

    #import GPG key
    gpgkey_path=`mktemp`
    curl -fsSL -o $gpgkey_path https://releases.usacloud.jp/hanami/repos/GPG-KEY-usacloud
    rpm --import $gpgkey_path
    rm $gpgkey_path

    cat >/etc/yum.repos.d/hanami.repo <<'EOF';
  [hanami]
  name=hanami
  baseurl=https://releases.usacloud.jp/hanami/repos/centos/$basearch
  gpgcheck=1
EOF

  yum install -y hanami

SCRIPT
}

install_by_apt {
  sudo sh <<'SCRIPT'
    set -x
    echo "deb https://releases.usacloud.jp/hanami/repos/debian /" > /etc/apt/sources.list.d/hanami.list
    curl -fsS https://releases.usacloud.jp/hanami/repos/GPG-KEY-usacloud | apt-key add -
    apt-get update -qq

  apt-get install -y hanami
SCRIPT
}
