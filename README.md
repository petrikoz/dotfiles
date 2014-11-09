# dotfiles #

My Linux dotfiles.

## Install ##

```
#!shell

git clone --recursive https://github.com/petrikoz/dotfiles.git ~/.dotfiles
```

### VIM ###

```
#!shell

ln -s ~/.dotfiles/.vim ~/.vim
ln -s ~/.vim/rc ~/.vimrc
vim +PluginInstall +qall
```

### ZSH ###

```
#!shell

ln -s ~/.dotfiles/.zsh ~/.zsh
ln -s ~/.zsh/env ~/.zshenv
ln -s ~/.zsh/rc ~/.zshrc
```

Install plugins:

```
#!shell

git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
```

Apply config:

```
#!shell

source ~/.zshenv
source ~/.zshrc
```

### TMUX ###

```
#!shell

ln -s ~/.dotfiles/.tmux ~/.tmux
ln -s ~/.tmux/conf ~/.tmux.conf
```

Go to `tmux` and press `prefix + I` for install plugins.

### Powerline ###

```
#!shell

pip install --user git+https://github.com/Lokaltog/powerline
ln -s ~/.dotfiles/powerline ~/.config/powerline
```
