# CONFIGS

Configs for most of my software.

## Install

```shell

sudo pacman -Suy git
git clone --recursive https://github.com/petrikoz/dotfiles.git
```

## Soft

This part contains instructions for install and config soft.

### common

```shell

sudo pacman -S - < $HOME/dotfiles/pkglist.txt
```

### cron

```shell

git clone https://aur.archlinux.org/systemd-cron.git
cd systemd-cron
makepkg -sri

sudo systemctl daemon-reload
sudo systemctl enable cron.target
sudo systemctl start cron.target

sudo ln -s $HOME/dotfiles/cron/check-updates /etc/cron.daily/
```

### fonts

```shell

ln -s $HOME/dotfiles/fonts $HOME/.fonts
fc-cache -f -v
```

### golang

```shell

mkdir -p $HOME/go/bin $HOME/go/pkg $HOME/go/src
```

### i3wm

```shell

ln -s $HOME/dotfiles/i3 $HOME/.i3
```

### lm_sensors

```shell

sudo sensors-detect --auto
```

### pmount

```shell

git clone https://aur.archlinux.org/pmount.git
cd pmount
makepkg -sri
```

### python

```shell

pip3 install --upgrade --user pip

ln -s $HOME/dotfiles/pip $HOME/.pip
pip install --requirement=$HOME/.pip/requirements.txt

ln -s $HOME/dotfiles/isort.cfg $HOME/.isort.cfg
```

### rofi-dmenu

```shell

git clone https://aur.archlinux.org/rofi-dmenu.git
cd rofi-dmenu
makepkg -sri
```

### rtorrent

```shell

ln -s $HOME/dotfiles/rtorrent $HOME/rtorrent
ln -s $HOME/rtorrent/rc $HOME/.rtorrent.rc
```

### st

```shell

cd $HOME/dotfiles/st
makepkg -sri
```

### sublime text

```shell

curl -O https://download.sublimetext.com/sublimehq-pub.gpg && sudo pacman-key --add sublimehq-pub.gpg && sudo pacman-key --lsign-key 8A8F901A && rm sublimehq-pub.gpg
echo -e "\n[sublime-text]\nServer = https://download.sublimetext.com/arch/stable/x86_64" | sudo tee -a /etc/pacman.conf
sudo pacman -Syu sublime-text
ln -sf $HOME/dotfiles/sublime-text  $HOME/.config/sublime-text-3/Packages/User
```

### tmux

```shell

ln -s $HOME/dotfiles/tmux $HOME/.tmux
ln -s $HOME/.tmux/conf $HOME/.tmux.conf
```

### todo.sh

```shell

ln -s $HOME/dotfiles/todo $HOME/.todo

git clone https://aur.archlinux.org/todotxt.git
cd todotxt
makepkg -sri
```

### vim

```shell

ln -s $HOME/dotfiles/vim $HOME/.vim
ln -s $HOME/.vim/rc $HOME/.vimrc

# replace vi with vim
git clone https://aur.archlinux.org/vi-vim-symlink.git
cd vi-vim-symlink
makepkg -sri
```

### xorg

```shell

ln -s $HOME/dotfiles/Xorg/xinitrc $HOME/.xinitrc
ln -s $HOME/dotfiles/Xorg/Xmodmap $HOME/.Xmodmap
sudo ln -s $HOME/dotfiles/Xorg/conf.d/40-libinput.conf /etc/X11/xorg.conf.d/
```

For two monitors add file `/etc/X11/xorg.conf.d/10-monitor.conf` with content like this:

```conf

Section "Monitor"
    Identifier  "DVI-0"
    Option      "PreferredMode" "2560x1600"
    Option      "Primary" "true"
EndSection

Section "Monitor"
    Identifier  "HDMI-0"
    Option      "RightOf" "DVI-0"
EndSection
```

### zsh

```shell

ln -s $HOME/dotfiles/zsh $HOME/.zsh
ln -s $HOME/.zsh/env $HOME/.zshenv
ln -s $HOME/.zsh/profile $HOME/.zprofile
ln -s $HOME/.zsh/rc $HOME/.zshrc
```
