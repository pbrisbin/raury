#!/bin/bash -e
#
# curl https://github.com/pbrisbin/raury/raw/master/install.sh | bash
#
# NOTE: this is only lightly tested. it shouldn't kill your cat but it
# might not always work.
#
##
ensure_we_have() {
  local bin=$1 cmd=$2

  if ! which $bin &>/dev/null; then
    echo "$bin is required but was not found." >&2
    echo "please run $cmd to remedy this."     >&2

    exit 1
  fi
}

using_sudo() {
  read -r -p 'do you need sudo to install gems? ' ans

  case $ans in
    Y*|y*) return 0 ;;
    *)     return 1 ;;
  esac
}

ok_go() {
  cat << EOF

This script will:

  1. Download latest ruary source

  2. Install missing gem dependencies

  3. Install the raury gem

If you have any concerns: use the source, Luke.

EOF

  read -r -p 'Continue? ' ans

  case $ans in
    Y*|y*) return 0 ;;
    *)     return 1 ;;
  esac
}

if ok_go; then
  ensure_we_have 'git'    'pacman -S git'
  ensure_we_have 'gem'    'pacman -S ruby'
  ensure_we_have 'bundle' 'gem install bundler'

  git clone https://github.com/pbrisbin/raury

  cd ./raury

  if using_sudo; then
    sudo bundle install
    sudo rake install
  else
    bundle install
    rake install
  fi
fi
