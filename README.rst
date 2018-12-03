*******
CONFIGS
*******

Configs for most of my software.

Install
=======

.. code-block:: shell

    sudo pacman -Suy git
    git clone --recursive https://github.com/petrikoz/dotfiles.git

Soft
====

This part contains instructions for install and config soft.

common
------

.. code-block:: shell

    sudo pacman -S - < $HOME/dotfiles/pkglist.txt

fonts
-----

.. code-block:: shell

    ln -s $HOME/dotfiles/fonts $HOME/.fonts
    fc-cache -f -v

golang
------

.. code-block:: shell

    ln -s $HOME/dotfiles/go $HOME/.go

i3wm
----

.. code-block:: shell

    ln -s $HOME/dotfiles/i3 $HOME/.i3

pmount
------

.. code-block:: shell

    git clone https://aur.archlinux.org/pmount.git
    cd pmount
    makepkg -sri

python
------

.. code-block:: shell

    pip3 install --upgrade --user pip

    ln -s $HOME/dotfiles/pip $HOME/.pip
    pip install --requirement=$HOME/.pip/requirements.txt

    ln -s $HOME/dotfiles/isort.cfg $HOME/.isort.cfg

rofi-dmenu
----------

.. code-block:: shell

    git clone https://aur.archlinux.org/rofi-dmenu.git
    cd rofi-dmenu
    makepkg -sri

rtorrent
--------

.. code-block:: shell

    ln -s $HOME/dotfiles/rtorrent.rc $HOME/.rtorrent.rc

st
--

.. code-block:: shell

    cd $HOME/dotfiles/st
    makepkg -sri

sublime text
------------

.. code-block:: shell

    curl -O https://download.sublimetext.com/sublimehq-pub.gpg && sudo pacman-key --add sublimehq-pub.gpg && sudo pacman-key --lsign-key 8A8F901A && rm sublimehq-pub.gpg
    echo -e "\n[sublime-text]\nServer = https://download.sublimetext.com/arch/stable/x86_64" | sudo tee -a /etc/pacman.conf
    sudo pacman -Syu sublime-text
    ln -sf $HOME/dotfiles/sublime-text  $HOME/.config/sublime-text-3/Packages/User

tmux
----

.. code-block:: shell

    ln -s $HOME/dotfiles/tmux $HOME/.tmux
    ln -s $HOME/.tmux/conf $HOME/.tmux.conf

vim
---

.. code-block:: shell

    ln -s $HOME/dotfiles/vim $HOME/.vim
    ln -s $HOME/.vim/rc $HOME/.vimrc

    # replace vi with vim
    git clone https://aur.archlinux.org/vi-vim-symlink.git
    cd vi-vim-symlink
    makepkg -sri

xorg
----

.. code-block:: shell

    ln -s $HOME/dotfiles/Xorg/xinitrc $HOME/.xinitrc
    ln -s $HOME/dotfiles/Xorg/Xmodmap $HOME/.Xmodmap


xkblayout-state
---------------

.. code-block:: shell

    git clone https://aur.archlinux.org/xkblayout-state-git.git
    cd xkblayout-state-git
    makepkg -sri

zsh
---

.. code-block:: shell

    ln -s $HOME/dotfiles/zsh $HOME/.zsh
    ln -s $HOME/.zsh/env $HOME/.zshenv
    ln -s $HOME/.zsh/profile $HOME/.zprofile
    ln -s $HOME/.zsh/rc $HOME/.zshrc
