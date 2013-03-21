#!/bin/sh
VIMHOME=~/.vim

warn() {
    echo "$1" >&2
}

die() {
    warn "$1"
    exit 1
}

[ -e "$VIMHOME/vimrc" ] && die "$VIMHOME/vimrc already exists."
[ -e "~/.vim" ] && die "~/.vim already exists."
[ -e "~/.vimrc" ] && die "~/.vimrc already exists."

# for commandT
sudo apt-get install ruby ruby-dev

git clone https://github.com/zmc963/vimrc.git "$VIMHOME"
cd "$VIMHOME"
git submodule update --init

# for id-utils and ack.vim
sudo apt-get install id-utils ack-grep

./install-vimrc.sh

cd bundle/command-t/ruby/command-t
(ruby extconf.rb && make) || warn "Can't compile Command-T."

echo "vgod's vimrc is installed."
