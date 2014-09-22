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
git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
source ~/.zshenv
source ~/.zshrc
```

### TMUX ###

```
ln -s ~/.dotfiles/.tmux ~/.tmux
ln -s ~/.tmux/conf ~/.tmux.conf
```


### Powerline ###

```
cp -r ~/.dotfiles/powerline ~/.config/powerline
```
