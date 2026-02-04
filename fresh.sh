#!/bin/bash

# # Make ZSH the default shell
# chsh -s $(which zsh)

# flags
FORCE_ZSHRC=false
for arg in "$@"; do
   case "$arg" in
      --force-zshrc)
         FORCE_ZSHRC=true
         ;;
   esac
done

####################### OH MY ZSH SETUP ########################

# install oh my zsh
if [ -d "$HOME/.oh-my-zsh" ]; then
   echo 'oh-my-zsh already installed; skipping'
else
   echo 'Installing oh-my-zsh'
   sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
fi

# zsh stuff
THEME_DIR=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
if [ -d "$THEME_DIR" ]; then
   echo 'powerlevel10k already installed; skipping'
else
   echo 'Installing powerlevel10k'
   git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$THEME_DIR"
fi

HIGHLIGHT_DIR=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
if [ -d "$HIGHLIGHT_DIR" ]; then
   echo 'zsh-syntax-highlighting already installed; skipping'
else
   echo 'Installing zsh-syntax-highlighting'
   git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HIGHLIGHT_DIR"
fi

AUTOSUGGEST_DIR=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
if [ -d "$AUTOSUGGEST_DIR" ]; then
   echo 'zsh-autosuggestions already installed; skipping'
else
   echo 'Installing zsh-autosuggestions'
   git clone https://github.com/zsh-users/zsh-autosuggestions "$AUTOSUGGEST_DIR"
fi

AUTOUPDATE_DIR=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/autoupdate
if [ -d "$AUTOUPDATE_DIR" ]; then
   echo 'autoupdate plugin already installed; skipping'
else
   echo 'Installing zsh autoupdate'
   git clone https://github.com/TamCore/autoupdate-oh-my-zsh-plugins "$AUTOUPDATE_DIR"
fi

# If a real file exists, keep a backup before replacing it
if [[ -f $HOME/.p10k.zsh && ! -L $HOME/.p10k.zsh ]]; then
   mv $HOME/.p10k.zsh $HOME/.p10k.zsh.old
fi
# Remove existing symlink so we can re-link to the repo version
if [[ -f $HOME/.p10k.zsh && -L $HOME/.p10k.zsh ]]; then
   rm $HOME/.p10k.zsh
fi
# Link powerlevel10k config from this repo
ln -s $PWD/p10k.zsh $HOME/.p10k.zsh

echo 'setup zshrc'
# Do not overwrite .zshrc (it may contain local, system-specific configs)
# Only create it if it doesn't exist yet, unless --force-zshrc is passed
if [[ ! -f $HOME/.zshrc || "$FORCE_ZSHRC" == true ]]; then
   if [[ -f $HOME/.zshrc && "$FORCE_ZSHRC" == true ]]; then
      echo 'Backing up existing .zshrc to .zshrc.old'
      mv $HOME/.zshrc $HOME/.zshrc.old
   fi
   cp $PWD/zshrc $HOME/.zshrc
   # Replaces all occurrences of the string 'DOTFILES_LOCATION' with the current working directory path ($PWD)
   # in the user's .zshrc file located at $HOME/.zshrc
   # Uses '+' as the sed delimiter to avoid escaping forward slashes in the path
   # The -i flag modifies the file in place
   # The -e flag specifies the sed expression to execute
   sed -i -e "s+DOTFILES_LOCATION+$PWD+g" $HOME/.zshrc
else
   echo '.zshrc exists; leaving it unchanged (use --force-zshrc to overwrite)'
   # Critical check: ensure dotfiles are active by sourcing zshrc_global
   ZSHRC_GLOBAL_LINE="source $PWD/zshrc_global"
   if ! grep -Fq "$ZSHRC_GLOBAL_LINE" $HOME/.zshrc; then
      # If the line is missing, dotfiles won't load; drop into bash instead of continuing
      echo "ERROR: ~/.zshrc does not source zshrc_global. Dotfiles will not be active."
      echo "Add this line to the top of ~/.zshrc: $ZSHRC_GLOBAL_LINE"
      echo "Launching bash shell instead of zsh setup."
      exec /bin/bash
   fi
fi


####################### GIT SETUP ########################

echo 'setting up git'
CURRENT_EMAIL=$(git config --global --get user.email)
CURRENT_NAME=$(git config --global --get user.name)
if [[ -z "$CURRENT_EMAIL" ]]; then
   git config --global user.email "Leander.Kurscheidt@gmx.de"
else
   echo "git user.email already set; skipping"
fi
if [[ -z "$CURRENT_NAME" ]]; then
   git config --global user.name "Leander Kurscheidt"
else
   echo "git user.name already set; skipping"
fi

# Install cona-zsh integration

# Check if conda is installed
if command -v conda &> /dev/null; then
   echo "conda is installed."
   # Idempotent: only run `conda init zsh` if the init block is missing from .zshrc.
   # This avoids duplicating the "# >>> conda initialize >>>" block on repeated runs.
   # We look for that exact marker line, which conda writes into .zshrc when initialized.
   if [[ -f $HOME/.zshrc ]] && grep -Fq "# >>> conda initialize >>>" $HOME/.zshrc; then
      echo "conda already initialized in .zshrc; skipping"
   else
      conda init zsh
   fi
else
   # Check if /opt/conda/bin exists
   if [ -d "/opt/conda/bin" ]; then
      echo "/opt/conda/bin exists."
      # Fallback: activate conda from /opt if it isn't on PATH
      source /opt/conda/bin/activate
      # Same idempotent check before initializing
      if [[ -f $HOME/.zshrc ]] && grep -Fq "# >>> conda initialize >>>" $HOME/.zshrc; then
         echo "conda already initialized in .zshrc; skipping"
      else
         conda init zsh
      fi
   else
      echo "conda not found. Please install manually with conda init zsh."
   fi
fi