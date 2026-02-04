all:

zsh_without_root:
	@echo "replacing bash_profile"; \
	if [ -f ${HOME}/.bash_profile ]; then \
		mv ${HOME}/.bash_profile ${HOME}/.bash_profile.old; \
	fi; \
	ln -s ${PWD}/bash_profile ${HOME}/.bash_profile

fresh:
	@echo "fresh install"; \
	./fresh.sh --force-zshrc \
	echo "sourcing .zshrc"; \
	source ${HOME}/.zshrc

update:
	@echo "updating dotfiles"; \
	./fresh.sh

# offload_cache: argument path is the path to the new chache location
# use via `make offload_cache path=/path/to/new/cache`
offload_cache:
	@echo "offloading cache"; \
	./offload_cache.sh ${path}

########### edinburgh uni specific kerberos setup ###########
########### not working yet ###########

# Validate tkinit presence
validate_tkinit:
	@echo "🔄 Validating 'tkinit' presence..."; \
	. $(HOME)/.zshrc.local; \
	if ! command -v tkinit &>/dev/null; then \
		echo "❌ 'tkinit' not found. Please install it before proceeding."; \
		exit 1; \
	fi
	@echo "✅ 'tkinit' is present. Proceeding with setup."

# Setup Kerberos refresh on login
setup_login:
	@echo "🔄 Setting up Kerberos refresh on login..."; \
	if ! grep -q "refresh_kerberos.sh" $(HOME)/.zshrc.local; then \
		echo "bash $(PWD)/edinburgh/bin/refresh_kerberos.sh" >> $(HOME)/.zshrc.local; \
	fi
	@echo "✅ Kerberos refresh setup for login."

# # Setup Kerberos refresh on network events
# setup_network:
# 	@echo "🔄 Setting up Kerberos refresh on network events..."; \
# 	echo "[Unit]\nDescription=Run refresh_kerberos on network events\n\n[Service]\nExecStart=$(PWD)/edinburgh/bin/refresh_kerberos.sh\n\n[Install]\nWantedBy=network-online.target" > /etc/systemd/system/refresh_kerberos_network.service; \
# 	systemctl enable refresh_kerberos_network.service; \
# 	systemctl start refresh_kerberos_network.service
# 	@echo "✅ Kerberos refresh setup for network events."

# Setup periodic Kerberos refresh
setup_periodic:
	@echo "🔄 Setting up periodic Kerberos refresh..."; \
	echo "[Unit]\nDescription=Run refresh_kerberos periodically\n\n[Timer]\nOnCalendar=hourly\n\n[Install]\nWantedBy=timers.target" > /etc/systemd/system/refresh_kerberos.timer; \
	echo "[Unit]\nDescription=Run refresh_kerberos periodically\n\n[Service]\nExecStart=$(PWD)/edinburgh/bin/refresh_kerberos.sh" > /etc/systemd/system/refresh_kerberos.service; \
	systemctl enable refresh_kerberos.timer; \
	systemctl start refresh_kerberos.timer
	@echo "✅ Periodic Kerberos refresh setup."

# Install all Kerberos-related setups
install_tkinit:
	@echo "🔄 Installing all Kerberos-related setups..."; \
	$(MAKE) validate_tkinit; \
	$(MAKE) setup_login; \
	$(MAKE) setup_network; \
	$(MAKE) setup_periodic
	@echo "✅ All Kerberos-related setups installed successfully."

# Clean up all setups
clean_kerberos:
	@echo "🧹 Cleaning up Kerberos refresh setups..."; \
	sed -i '/refresh_kerberos.sh/d' $(HOME)/.zshrc.local; \
	systemctl disable refresh_kerberos_network.service; \
	systemctl stop refresh_kerberos_network.service; \
	rm -f /etc/systemd/system/refresh_kerberos_network.service; \
	systemctl disable refresh_kerberos.timer; \
	systemctl stop refresh_kerberos.timer; \
	rm -f /etc/systemd/system/refresh_kerberos.timer /etc/systemd/system/refresh_kerberos.service
	@echo "✅ Cleaned up all Kerberos refresh setups."