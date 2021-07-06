# CONFIGS #

Configs for most of my software.

## Install ##

```shell

sudo pacman -Suy base-devel git
git clone --recursive https://github.com/petrikoz/dotfiles.git
```

## Soft ##

This part contains instructions for install and config soft.

### common ###

```shell

sudo pacman -S - < $HOME/dotfiles/pacman/pkglist/common.txt
```

Specific files in `pacman/pkglist/`:

* `common.txt` — soft for any Arch-based-installation
* `artix.txt` — soft actual only on [Artix Linux](https://artixlinux.org/)
* `desktop.txt` — only for desktop PC
* `desktop-aur.txt` — soft from [AUR](https://aur.archlinux.org/) for desktop PC
* `i3.txt` — soft actual for installation with [i3wm](https://wiki.archlinux.org/title/I3) on common cases
* `i3-laptop.txt` — soft actual for installation with i3wm on laptop
* `kde.txt` — soft actual for installation with [kde](https://wiki.archlinux.org/title/KDE)

### ccat ###

First install Golang: see bellow.

```shell
go get -u github.com/owenthereal/ccat
```

### conky ###

```shell

ln -s $HOME/dotfiles/conkyrc $HOME/.conkyrc
```

### cron ###

#### fsTRIM ####

Actual only for Artix Linux. On systemd-based distros periodic [TRIM](https://wiki.archlinux.org/title/Solid_state_drive#TRIM) run as default

```shell

sudo cp $HOME/dotfiles/cron/weekly/fstrim /etc/cron.weekly/
sudo chmod +x /etc/cron.weekly/fstrim
```

#### Cloud backup ####

```shell

crontab -e
```

```cron

0 16 * * *    $HOME/dotfiles/cron/user/cloud-backup.sh > $HOME/dotfiles/cron/user/cloud-backup.log 2>&1
```


#### SystemD ####

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

### Docker ###

```shell

# add itself to 'docker' group
sudo usermod -aG docker $USER

# Add custom network ([docs](https://docs.docker.com/engine/reference/commandline/network_create/))
docker network create -o "com.docker.network.bridge.name"="docker1" docker1
```

Hide connections from [NetworkManager](https://wiki.archlinux.org/title/NetworkManager)

```shell

sudo vi /etc/NetworkManager/conf.d/unmanaged.conf
```

```conf

[keyfile]
unmanaged-devices=interface-name:docker*;interface-name:veth*
```

### firejail ###

Run applications with security profiles:


```shell

# generate symlinks for default supported applications
sudo firecfg

# allow PulseAudio in jailed apps
firecfg --fix-audio

# add extra profiles
ln -s $HOME/dotfiles/firejail/profiles $HOME/.config/firejail
```

Run games with firejail

```shell

mkdir $HOME/games
firejail --profile=game "GAME-DIR-IN-games-LOCAL-DIR/start.sh"

# can use desktop entry for run game
mkdir -p $HOME/.local/share/applications
cp $HOME/dotfiles/firejail/game.desktop $HOME/.local/share/applications/GAME-NAME.desktop
vi $HOME/.local/share/applications/GAME-NAME.desktop
```

### fonts ###

```shell

git clone https://aur.archlinux.org/nerd-fonts-dejavu-complete.git
cd nerd-fonts-dejavu-complete
makepkg -irs
```

### golang ###

```shell

mkdir -p $HOME/go/bin $HOME/go/pkg $HOME/go/src
```

### i3wm ###

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

#### netctl ####

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

#### rofi-dmenu ####

```shell

git clone https://aur.archlinux.org/rofi-dmenu.git
cd rofi-dmenu
makepkg -irs

ln -s $HOME/dotfiles/i3/rofi $HOME/.config/
```

#### st ####

```shell

git clone https://aur.archlinux.org/st.git
cd st
cp config.def.h config.h
# move differences from `$HOME/dotfiles/st/config.h` to `config.h`
# then run:
makepkg -irs
```

#### xorg ####

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

### KDE ###

#### EncFS ####

Mount encfs volumes with passwords from Kwallet:

```shell

echo '#!/bin/sh

kdeencfs="$HOME/dotfiles/kde/kdeencfs.sh"

$kdeencfs /path/of/encrypted/target /path/to/mount/point
' > $HOME/dotfiles/kde/autostart/kdeencfs

cp $HOME/dotfiles/kde/autostart/kdeencfs.desktop $HOME/.config/autostart/
```

#### SSH ###

Add SSH's keys to SSH Agent on logon:

```shell

cp $HOME/dotfiles/kde/askpass.sh $HOME/.config/plasma-workspace/env/

echo '#!/bin/sh

/usr/bin/ssh-add -q /home/petr/.ssh/id_key1 /home/petr/.ssh/id_key2 < /dev/null

# if sshmnt installed on system uncomment bellow
#sshmnt -m cloud.wormhole
' >  $HOME/dotfiles/kde/autostart/ssh-staff
chmod 700 $HOME/dotfiles/kde/autostart/ssh-staff

cp $HOME/dotfiles/kde/autostart/ssh-staff.desktop $HOME/.config/autostart/
```

### mpv ###

```shell

mkdir -p $HOME/.config/mpv
ln -s $HOME/dotfiles/mpv/mpv.conf $HOME/.config/mpv/
```

### pacman ###

```shell

# enable color output
sudo sed -i "/^#Color/c\Color" /etc/pacman.conf

# add hooks
sudo cp -r $HOME/dotfiles/pacman/hooks /etc/pacman.d/
```

Install packages from `pacman/pkglist/aur.txt`:

```shell

cd ~/Downloads
git clone https://aur.archlinux.org/PACKAGE-NAME.git
cd ~/Downloads/PACKAGE-NAME
makepkg -irs
```

### python ###

```shell

pip3 install --upgrade --user pip setuptools wheel
pip install --requirement=$HOME/dotfiles/pip-reqs.txt
```

### rclone ###

```shell

curl -O https://downloads.rclone.org/rclone-current-linux-amd64.zip && x rclone-current-linux-amd64.zip
mkdir -p $HOME/.local/bin && mv rclone-*/rclone $HOME/.local/bin/
rm -rf rclone-*
```

### sshmnt ###

```shell

# install
git clone https://aur.archlinux.org/sshmnt.git
cd sshmnt
makepkg -irs

# configure
ln -s $HOME/dotfiles/sshmntconfig $HOME/.config/sshmntconfig
```

### sublime text ###

```shell

curl -O https://download.sublimetext.com/sublimehq-pub.gpg && sudo pacman-key --add sublimehq-pub.gpg && sudo pacman-key --lsign-key 8A8F901A && rm sublimehq-pub.gpg
echo -e "\n[sublime-text]\nServer = https://download.sublimetext.com/arch/stable/x86_64" | sudo tee -a /etc/pacman.conf
sudo pacman -Syu sublime-text

ln -sf $HOME/dotfiles/sublime-text  $HOME/.config/sublime-text-3/Packages/User
```

### tmux ###

```shell

ln -s $HOME/dotfiles/tmux $HOME/.tmux
ln -s $HOME/.tmux/conf $HOME/.tmux.conf
```

### todo.sh ###

```shell

# install
git clone https://aur.archlinux.org/todotxt.git
cd todotxt
makepkg -irs

# configure
ln -s $HOME/cloud/todo $HOME/.todo
```

### vim ###

```shell

ln -s $HOME/dotfiles/vim $HOME/.vim
ln -s $HOME/.vim/rc $HOME/.vimrc

# replace vi with vim
git clone https://aur.archlinux.org/vi-vim-symlink.git
cd vi-vim-symlink
makepkg -irs
```

### zsh ###

```shell

ln -s $HOME/dotfiles/zsh $HOME/.zsh
ln -s $HOME/.zsh/env $HOME/.zshenv
ln -s $HOME/.zsh/profile $HOME/.zprofile
ln -s $HOME/.zsh/rc $HOME/.zshrc
```
