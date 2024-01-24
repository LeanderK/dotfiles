#!/bin/bash

# # Make ZSH the default shell
# chsh -s $(which zsh)

# install oh my zsh
echo 'Install oh-my-zsh'
rm -rf $HOME/.oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# zsh stuff
echo 'Install powerlevel10k'
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

echo 'Install zsh-syntax-highlighting'
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

echo 'Install zsh-autosuggestions'
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

echo 'Install zsh autoupdate'
git clone https://github.com/TamCore/autoupdate-oh-my-zsh-plugins $ZSH_CUSTOM/plugins/autoupdate

echo 'symlink dotfiles'
if [ -f $HOME/.zshrc ]; then
   mv $HOME/.zshrc $HOME/.zshrc.old
fi
ln -s zshrc $HOME/.zshrc

if [ -f $HOME/.p10k.zsh ]; then
   mv $HOME/.p10k.zsh $HOME/.p10k.zsh.old
fi
ln -s p10k.zsh $HOME/.p10k.zsh