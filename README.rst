*******
CONFIGS
*******

Configs for most of my software.

Install
=======

.. code-block:: shell

    sudo apt install git
    git clone --recursive https://github.com/petrikoz/dotfiles.git

Soft
====

This part contains instructions for install and config soft.

common
------

.. code-block:: shell

    sudo apt install \
        apt-transport-https \
        landscape-common \
        shadowsocks-libev \
        telegram-desktop \
        update-notifier-common

fonts
-----

.. code-block:: shell

    ln -s $HOME/dotfiles/fonts $HOME/.fonts
    fc-cache -f -v

golang
------

.. code-block:: shell

    sudo apt install golang-go
    ln -s $HOME/dotfiles/go $HOME/.go

i3wm
----

.. code-block:: shell

    /usr/lib/apt/apt-helper download-file http://debian.sur5r.net/i3/pool/main/s/sur5r-keyring/sur5r-keyring_2018.01.30_all.deb keyring.deb SHA256:baa43dbbd7232ea2b5444cae238d53bebb9d34601cc000e82f11111b1889078a
    sudo dpkg -i ./keyring.deb
    echo "deb http://debian.sur5r.net/i3/ $(grep '^DISTRIB_CODENAME=' /etc/lsb-release | cut -f2 -d=) universe" | sudo tee /etc/apt/sources.list.d/sur5r-i3.list
    sudo apt update
    sudo apt install i3 xinit

python
------

.. code-block:: shell

    sudo apt install python3 python3-dev python3-pip
    pip3 install --upgrade --user pip

    ln -s $HOME/dotfiles/pip $HOME/.pip
    pip install --requirement=$HOME/.pip/requirements.txt

    ln -s $HOME/dotfiles/isort.cfg $HOME/.isort.cfg

smplayer
--------

.. code-block:: shell

    sudo add-apt-repository ppa:rvm/smplayer
    sudo apt update
    sudo apt install smplayer

sublime text
------------

.. code-block:: shell

    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
    echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
    sudo apt update
    sudo apt install sublime-text
    ln -sf $HOME/dotfiles/sublime-text  $HOME/.config/sublime-text-3/Packages/User

tmux
----

.. code-block:: shell

    sudo apt install tmux
    ln -s $HOME/dotfiles/tmux $HOME/.tmux
    ln -s $HOME/.tmux/conf $HOME/.tmux.conf

vim
---

.. code-block:: shell

    sudo apt install vim
    ln -s $HOME/dotfiles/vim $HOME/.vim
    ln -s $HOME/.vim/rc $HOME/.vimrc

zsh
---

.. code-block:: shell

    sudo apt install zsh
    ln -s $HOME/dotfiles/zsh $HOME/.zsh
    ln -s $HOME/.zsh/env $HOME/.zshenv
    ln -s $HOME/.zsh/rc $HOME/.zshrc
