# CONFIGS

Configs for most of my software.

## Install

```shell

sudo pacman -Suy base-devel git
git clone --recursive https://github.com/petrikoz/dotfiles.git
```

## Soft

This part contains instructions for install and config soft.

### common

```shell

sudo pacman -S - < $HOME/dotfiles/pacman/pkglist/common.txt
```

For desktop use `pkglist/desktop.txt`. For laptop `pkglist/laptop.txt`.

### cron

Use systemd's timers as replacement for cron

```shell

# Check updates
sudo cp $HOME/dotfiles/systemd/check-updates/* /etc/systemd/system/
systemctl enable check-updates.timer

# Cloud backup
systemctl --user enable $HOME/dotfiles/systemd/user/cloud-backup/cloud-backup.service
systemctl --user enable $HOME/dotfiles/systemd/user/cloud-backup/cloud-backup.timer
systemctl --user start cloud-backup.timer
```

### firejail

Example how run GOG game with firejail:

```shell

firejail --profile=$HOME/dotfiles/firejail/gog.profile "GAME-DIR-IN-games-LOCAL-DIR/start.sh"
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

For enable blocks:

```shell

# lm_sensors
sudo sensors-detect --auto

# hddtemp
# for run only on localhost add in 'ExecStart': `-l 127.0.0.1`
sudo systemctl enable hddtemp.service
sudo systemctl start hddtemp.service
```

### mpv

```shell

mkdir -p $HOME/.config/mpv
ln -s $HOME/dotfiles/mpv.conf $HOME/.config/mpv/
```

### netctl

For more information see https://wiki.archlinux.org/index.php/Netctl

See network interfaces:

```shell

ip link
```

Enable systemd service:

```shell

sudo systemctl enable netctl-auto@INTERFACE.service
sudo systemctl start netctl-auto@INTERFACE.service
```

### pacman

```shell

sudo cp -r $HOME/dotfiles/pacman/hooks /etc/pacman.d/
```

### python

```shell

pip3 install --upgrade --user pip setuptools wheel
pip install --requirement=$HOME/dotfiles/pip-reqs.txt
```

### rclone

```shell

curl -O https://downloads.rclone.org/rclone-current-linux-amd64.zip && x rclone-current-linux-amd64.zip
mkdir -p $HOME/.local/bin && mv rclone-*/rclone $HOME/.local/bin/
rm -rf rclone-*
```

### rofi-dmenu

```shell

git clone https://aur.archlinux.org/rofi-dmenu.git
cd rofi-dmenu
makepkg -irs

ln -s $HOME/dotfiles/i3/rofi $HOME/.config/
```

### st

```shell

cd $HOME/dotfiles/st
makepkg -irs
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
makepkg -irs
```

### vim

```shell

ln -s $HOME/dotfiles/vim $HOME/.vim
ln -s $HOME/.vim/rc $HOME/.vimrc

# replace vi with vim
git clone https://aur.archlinux.org/vi-vim-symlink.git
cd vi-vim-symlink
makepkg -irs
```

### xorg

```shell

ln -s $HOME/dotfiles/Xorg/xinitrc $HOME/.xinitrc
ln -s $HOME/dotfiles/Xorg/xserverrc $HOME/.xserverrc
ln -s $HOME/dotfiles/Xorg/xxkbrc $HOME/.xxkbrc
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
