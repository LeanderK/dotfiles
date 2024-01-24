all:

zsh_without_root:
	@echo "replacing bash_profile"
	if [ -f $HOME/.bash_profile ]; then
		mv $HOME/.bash_profile $HOME/.bash_profile.old
	fix
	ln -s bash_profile $HOME/.bash_profile

fresh:
	@echo "fresh install"
	./fresh.sh