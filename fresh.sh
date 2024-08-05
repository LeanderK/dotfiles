#!/bin/bash

# # Make ZSH the default shell
# chsh -s $(which zsh)

# install oh my zsh
echo 'Install oh-my-zsh'
rm -rf $HOME/.oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc

# zsh stuff
echo 'Install powerlevel10k'
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

echo 'Install zsh-syntax-highlighting'
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

echo 'Install zsh-autosuggestions'
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

echo 'Install zsh autoupdate'
git clone https://github.com/TamCore/autoupdate-oh-my-zsh-plugins ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/autoupdate

echo 'setup dotfiles'
if [[ -f $HOME/.zshrc && ! -L $HOME/.zshrc ]]; then
   mv $HOME/.zshrc $HOME/.zshrc.old
fi
if [[ -f $HOME/.zshrc && -L $HOME/.zshrc ]]; then
   rm $HOME/.zshrc
fi
cp $PWD/zshrc $HOME/.zshrc
sed -i -e "s+DOTFILES_LOCATION+$PWD+g" $HOME/.zshrc
#ln -s $PWD/zshrc $HOME/.zshrc

if [[ -f $HOME/.p10k.zsh && ! -L $HOME/.p10k.zsh ]]; then
   mv $HOME/.p10k.zsh $HOME/.p10k.zsh.old
fi
if [[ -f $HOME/.p10k.zsh && -L $HOME/.p10k.zsh ]]; then
   rm $HOME/.p10k.zsh
fi
ln -s $PWD/p10k.zsh $HOME/.p10k.zsh

echo 'setting up git'
git config --global user.email "Leander.Kurscheidt@gmx.de"
git config --global user.name "Leander Kurscheidt"

# Install cona-zsh integration

# Check if conda is installed
if command -v conda &> /dev/null
then
   echo "conda is installed."
   conda init zsh
else
   # Check if /opt/conda/bin exists
   if [ -d "/opt/conda/bin" ]; then
      echo "/opt/conda/bin exists."
      source /opt/conda/bin/activate
      conda init zsh
   else
      echo "conda not found. Please install manually with conda init zsh."
   fi
fi