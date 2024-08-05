all:

zsh_without_root:
	@echo "replacing bash_profile"; \
	if [ -f ${HOME}/.bash_profile ]; then \
		mv ${HOME}/.bash_profile ${HOME}/.bash_profile.old; \
	fi; \
	ln -s ${PWD}/bash_profile ${HOME}/.bash_profile

fresh:
	@echo "fresh install"; \
	./fresh.sh

# offload_cache: argument path is the path to the new chache location
# use via `make offload_cache path=/path/to/new/cache`
offload_cache:
	@echo "offloading cache"; \
	./offload_cache.sh ${path}