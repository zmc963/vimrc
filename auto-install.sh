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

# inconsolata font
sudo apt-get install ttf-inconsolata

# for commandT
sudo apt-get install ruby ruby-dev

# for youcompleteme
sudo apt-get install libncurses5-dev libgnome2-dev libgnomeui-dev \
libgtk2.0-dev libatk1.0-dev libbonoboui2-dev \
libcairo2-dev libx11-dev libxpm-dev libxt-dev python-dev ruby-dev mercurial

sudo apt-get remove vim vim-runtime gvim   

cd ~
hg clone https://code.google.com/p/vim/
cd vim
./configure --with-features=huge \
            --enable-rubyinterp \
            --enable-pythoninterp \
            --enable-perlinterp \
            --enable-gui=gtk2 --enable-cscope --prefix=/usr
make VIMRUNTIMEDIR=/usr/share/vim/vim73 -j4
sudo make install

if [ `file /sbin/init | grep "32-bit"` -eq 0 ]; then
    wget -O /tmp/clang.tar.gz http://llvm.org/releases/3.2/clang+llvm-3.2-x86-linux-ubuntu-12.04.tar.gz
elif [ `file /sbin/init | grep "64-bit"` -eq 0 ]; then
    wget -O /tmp/clang.tar.gz http://llvm.org/releases/3.2/clang+llvm-3.2-x86_64-linux-ubuntu-12.04.tar.gz
fi
mkdir /tmp/llvm_root_dir
tar -xvf /tmp/clang.tar.gz -C /tmp/llvm_root_dir/
CLANG_TAR_NAME="`ls /tmp/llvm_root_dir | grep -i clang | grep -v tar`"

sudo apt-get install cmake python-dev build-essential

# for id-utils and ack.vim
sudo apt-get install id-utils ack-grep

# for global
wget -O /tmp/global.tar.gz ftp://ftp.gnu.org/pub/gnu/global/global-6.2.8.tar.gz
tar -xvf /tmp/global.tar.gz -C /tmp
GLOBAL_TAR_NAME="`ls /tmp | grep -i global | grep -v tar`"
cd /tmp/"$GLOBAL_TAR_NAME"
./configure
make -j4
sudo make install

# install vim 
git clone https://github.com/zmc963/vimrc.git "$VIMHOME"
cd "$VIMHOME"
git submodule update --init

./install-vimrc.sh

# for command-t
cd bundle/command-t/ruby/command-t
(ruby extconf.rb && make) || warn "Can't compile Command-T."

# for youcompleteme
cd /tmp
mkdir ycm_build
cd !$
cmake -G "Unix Makefiles" -DPATH_TO_LLVM_ROOT=/tmp/llvm_root_dir/"$CLANG_TAR_NAME" . ~/.vim/bundle/YouCompleteMe/cpp
make ycm_core -j4

#cd ~/.vim/bundle/YouCompleteMe
#./install.sh --clang-completer
cp /tmp/llvm_root_dir/"$CLANG_TAR_NAME"/lib/libclang.so ~/.vim/bundle/YouCompleteMe/python

# for global
mkdir -p ~/.vim/bundle/gtags/plugin
cp /usr/local/share/gtags/gtags.vim !$

echo "vgod's vimrc is installed."
