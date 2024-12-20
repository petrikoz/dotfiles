# CONFIGS

Configs for most of my software.

## Install

```shell

sudo pacman -Suy base-devel git
git clone --recursive https://github.com/petrikoz/dotfiles.git
```

## Project

```shell

cp -r $HOME/dotfiles/project PROJECT_PATH/PROJECT_NAME
cd PROJECT_PATH/PROJECT_NAME
mv editorconfig .editorconfig
mv flake8 .flake8
mv envrc .envrc && direnv allow
mv sublime-project $(basename $PWD).sublime-project
poetry install --no-root
git clone PROJECT_REPO src
# for ITCase's projects only:
mkdir itcase-dev
cd itcase-dev
git clone git@github.com:ITCase/itcase-common.git
pip install -e $PROJECT_ROOT/itcase-dev/itcase-common
```

## Soft

This part contains instructions for install and config soft.
All soft separated in files by desktop / laptop and common / specific usage.
See `$HOME/dotfiles/pacman/pkglist` directory:

* **artix.txt** — soft required for systems on [Artix Linux](https://artixlinux.org/)
* **common.txt** — soft required for all systems
* **common-aur.txt** — soft required for all systems, but available only in [AUR](https://aur.archlinux.org/)
* **desktop.txt** — soft required for desktop PC
* **i3.txt** — soft required for all systems with [i3wm](https://wiki.archlinux.org/title/I3)
* **i3-laptop.txt** — soft required for laptop with [i3wm](https://wiki.archlinux.org/title/I3)
* **kde.txt** — soft required for systmes with [KDE](https://wiki.archlinux.org/title/KDE)

### Artix

Add [Universe repo](https://wiki.artixlinux.org/Main/Repositories#Universe):

```shell
sudo cat <<EOT >> /etc/pacman.conf
# Universe is a repository maintained by Artix package maintainers and
# contains some programs which are not provided in the 4 main
# repositories - mostly programs from the AUR
[universe]
Server = https://universe.artixlinux.org/\$arch
Server = https://mirror1.artixlinux.org/universe/\$arch
Server = https://mirror.pascalpuffke.de/artix-universe/\$arch
Server = https://artixlinux.qontinuum.space:4443/artixlinux/universe/os/\$arch
Server = https://mirror1.cl.netactuate.com/artix/universe/\$arch

EOT
```

After install `artix-archlinux-support` package inable it:

```shell
sudo cat <<EOT >> pacman.conf
# Arch repositories from artix-archlinux-support
[extra]
Include = /etc/pacman.d/mirrorlist-arch
[community]
Include = /etc/pacman.d/mirrorlist-arch
#[multilib]
#Include = /etc/pacman.d/mirrorlist-arch

EOT
sudo pacman-key --populate archlinux
sudo pacman -Sy
```

Regular packages install with `pacman`. Ex.:

```shell

sudo pacman -S - < $HOME/dotfiles/pacman/pkglist/common.txt
```

AUR-packages should clone with git and install with `makepkg`. Ex.:

```shell

cd $HOME/Downloads
while read i; do
    git clone "https://aur.archlinux.org/$i.git"
    cd "$i"
    makepkg -irs --noconfirm
    cd ..
    rm -rf "$i"
done < "$HOME/dotfiles/pacman/pkglist/common-aur.txt"
```

### cron

#### fsTRIM

Actual only for Artix Linux. On systemd-based distros periodic TRIM run as default

```shell
sudo sh -c "(crontab -l ; echo '0 1 * * 5    /usr/bin/fstrim -av > /var/log/trim.log 2>&1') | sort - | uniq - | crontab -"
```

#### Cloud backup

```shell

(crontab -l ; echo "0 11 * * 1,3,5,6    $HOME/dotfiles/cron/user/cloud-backup.sh > $HOME/dotfiles/cron/user/cloud-backup.log 2>&1") | sort - | uniq - | crontab -
```

### direnv

```shell

ln -s $HOME/dotfiles/direnv $HOME/.config/
```
### firejail

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

### git

```shell

ln -s $HOME/dotfiles/gitconfig $HOME/.gitconfig
```

### golang

```shell

mkdir -p $HOME/go/bin $HOME/go/pkg $HOME/go/src
```

### grub

Hide GRUB unless the Shift key is held down:

```shell

sudo cat <<EOT >> /etc/default/grub
# Hide GRUB unless the Shift key is held down
GRUB_FORCE_HIDDEN_MENU="true"
EOT

sudo cp $HOME/dotfiles/grub/31_hold_shift /etc/grub.d/
sudo chmod a+x /etc/grub.d/31_hold_shift

sudo grub-mkconfig -o /boot/grub/grub.cfg
```

### i3wm

Directory `$HOME/dotfiles/i3wm` contains configs for soft which used with [i3wm](https://wiki.archlinux.org/title/I3).

#### i3

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

#### conky

```shell

ln -s $HOME/dotfiles/conkyrc $HOME/.conkyrc
```

#### netctl

For more information see https://wiki.archlinux.org/index.php/Netctl

See network interfaces:

```shell

ip link
```

#### rofi-dmenu

```shell

ln -s $HOME/dotfiles/i3/rofi $HOME/.config/
```

#### st

```shell

git clone https://aur.archlinux.org/st.git
cd st
cp config.def.h config.h
# move differences from `$HOME/dotfiles/st/config.h` to `config.h`
# then run:
makepkg -irs
```

#### xorg

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

### KDE

#### EncFS

Mount encfs volumes with passwords from Kwallet:

```shell

echo '#!/bin/sh

kdeencfs="$HOME/dotfiles/kde/kdeencfs.sh"

$kdeencfs /path/of/encrypted/target /path/to/mount/point
' > $HOME/dotfiles/kde/autostart/kdeencfs

cp $HOME/dotfiles/kde/autostart/kdeencfs.desktop $HOME/.config/autostart/
```

#### NetworkManager

Enable WireGuard-connection: copy needed config from cloud backup. Ex.:

```shell

sudo cp CLOUD-BACKUP-DIRECTORY/soft/NetworkManager/system-connections/petr-desktop-wg0.nmconnection /etc/NetworkManager/system-connections/wg0.nmconnection
sudo chmod -R 600 /etc/NetworkManager/system-connections/wg0.nmconnection
```

#### SSH

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

### mpv

```shell

mkdir -p $HOME/.config/mpv
ln -s $HOME/dotfiles/mpv/mpv.conf $HOME/.config/mpv/
```

### pacman

```shell

# enable color output
sudo sed -i "/^#Color/c\Color" /etc/pacman.conf

# comparing versions before updating
sudo sed -i "/^#VerbosePkgLists/c\VerbosePkgLists" /etc/pacman.conf

# comparing versions before updating
sudo sed -i "/^#ParallelDownloads = 5/c\ParallelDownloads = 16" /etc/pacman.conf

# add hooks
sudo cp -r $HOME/dotfiles/pacman/hooks /etc/pacman.d/
```

### pam_mount

Auto mount LUKS partition and tmpfs volume: edit part 'Volumes' in `/etc/security/pam_mount.conf.xml`.
Example (replace all variables with `<>` around):

```xml

<!-- LUKS -->
<volume user="<USERNAME>" fstype="crypt" path="/dev/disk/by-uuid/<UUID-OF-LUKS-PARTITION>" mountpoint="~" options="allow_discard,crypto_name=home-<USERNAME>,fsck" />

<!-- User's cache in memory -->
<volume user="<USERNAME>" fstype="tmpfs" path="tmpfs" mountpoint="~/.cache" options="size=1G,noexec,nodev,nosuid,uid=%(USER),gid=%(USER),mode=1700" />
```

[Enable `pam_mount` in login manager](https://wiki.archlinux.org/title/Pam_mount#Login_manager_configuration)

### podman

```shell

sudo touch /etc/subuid /etc/subgid
sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 $USER
```

### python

```shell

pip install --break-system-packages --user --upgrade --requirement=$HOME/dotfiles/pip-reqs.txt
```

### rclone

Add config from cloud backup to `$HOME/.config/rclone/`

### sshmnt

```shell

ln -s $HOME/dotfiles/sshmntconfig $HOME/.config/sshmntconfig
```

### sublime text

```shell

curl -O https://download.sublimetext.com/sublimehq-pub.gpg && sudo pacman-key --add sublimehq-pub.gpg && sudo pacman-key --lsign-key 8A8F901A && rm sublimehq-pub.gpg
echo -e "\n[sublime-text]\nServer = https://download.sublimetext.com/arch/stable/x86_64" | sudo tee -a /etc/pacman.conf
sudo pacman -Syu sublime-text

mkdir -p $HOME/.config/sublime-text/Packages
git clone git@github.com:shiyanhui/FileHeader.git $HOME/.config/sublime-text/Packages/FileHeader
ln -sf $HOME/dotfiles/sublime-text  $HOME/.config/sublime-text/Packages/User
sudo chattr +i $HOME/dotfiles/sublime-text/Markdown.sublime-settings
```

### Sudo

Allow 'wheel' group use `sudo`:

```shell

sudo cp $HOME/dotfiles/sudo/g_wheel /etc/sudoers.d/
```

### sysctl

```shell

sudo cp $HOME/dotfiles/sysctl/99-sysctl.conf /etc/sysctl.d/
```

### tmux

```shell

ln -s $HOME/dotfiles/tmux $HOME/.tmux
ln -s $HOME/.tmux/conf $HOME/.tmux.conf
```

### todo.sh

```shell

ln -s $HOME/Nextcloud/todo $HOME/.todo
```

### vim

```shell

ln -s $HOME/dotfiles/vim $HOME/.vim
ln -s $HOME/.vim/rc $HOME/.vimrc
```

### zsh

```shell

ln -s $HOME/dotfiles/zsh $HOME/.zsh
ln -s $HOME/.zsh/env $HOME/.zshenv
ln -s $HOME/.zsh/profile $HOME/.zprofile
ln -s $HOME/.zsh/rc $HOME/.zshrc
ln -s $HOME/.zsh/p10k.zsh $HOME/.p10k.zsh
```
