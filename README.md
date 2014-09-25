# dotfiles #

My Linux dotfiles.

## Install ##

```
git clone git@github.com:petrikoz/dotfiles.git ~/.dotfiles
```

### VIM ###

```
ln -s ~/.dotfiles/.vim ~/.vim
ln -s ~/.vim/rc ~/.vimrc
vim +PluginInstall +qall
```

### ZSH ###

```
ln -s ~/.dotfiles/.zsh ~/.zsh
ln -s ~/.zsh/env ~/.zshenv
ln -s ~/.zsh/rc ~/.zshrc
```

Install plugins:

```
git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
```

Apply config:

```
source ~/.zshenv
source ~/.zshrc
```

### TMUX ###

```
ln -s ~/.dotfiles/.tmux ~/.tmux
ln -s ~/.tmux/conf ~/.tmux.conf
```

Go to `tmux` and press `prefix + I` for install plugins.

### Powerline ###

```
cp -r ~/.dotfiles/powerline ~/.config/powerline
```
