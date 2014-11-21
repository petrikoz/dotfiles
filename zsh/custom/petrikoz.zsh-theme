
  # GIT prompt
  ZSH_THEME_GIT_PROMPT_PREFIX="%{$reset_color%}%{$fg[blue]%}"
  ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}%{$fg[red]%}|"
  ZSH_THEME_GIT_PROMPT_DIRTY="%{$reset_color%}|%{$fg[red]%}✗"
  ZSH_THEME_GIT_PROMPT_CLEAN="%{$reset_color%}|%{$fg[green]%}✔"

  # VENV prompt
  ZSH_THEME_VENV_PROMPT_PREFIX="%{$reset_color%}ⓔ %{$fg[green]%}"
  ZSH_THEME_VENV_PROMPT_SUFFIX="%{$reset_color%}%{$fg[red]%}|"

  function venv_prompt_info() {
    if [[ -n $VIRTUAL_ENV ]]; then
      echo "$ZSH_THEME_VENV_PROMPT_PREFIX`basename $VIRTUAL_ENV`$ZSH_THEME_VENV_PROMPT_SUFFIX"
    fi
  }

  PROMPT=$'%{$reset_color%}%{$fg[magenta]%}%n'          # Username
  PROMPT=$PROMPT$'%{$reset_color%}%{$fg[cyan]%}@'       # @
  PROMPT=$PROMPT$'%{$reset_color%}%{$fg[yellow]%}%m'    # Hostname
  PROMPT=$PROMPT$'%{$reset_color%}%{$fg[red]%}:'        # :
  PROMPT=$PROMPT$'%{$reset_color%}%{$fg[cyan]%}%0~'     # Current directory
  PROMPT=$PROMPT$'%{$reset_color%}%{$fg[red]%}|'        # |
  PROMPT=$PROMPT$'%{$reset_color%}$(venv_prompt_info)'  # Virtualenv prompt
  PROMPT=$PROMPT$'%{$reset_color%}$(git_prompt_info)'   # Git prompt
  PROMPT=$PROMPT$'%{$reset_color%}\n%{$fg[cyan]%}⇒'     # ⇒
  PROMPT=$PROMPT$'%{$reset_color%} '                    # Prompt welcome
