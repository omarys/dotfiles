.PHONY: stow provision setup help

setup: stow provision ## Run the full setup (Stow dotfiles and run Ansible)

stow: ## Symlink all dotfiles
	@echo "Symlinking dotfiles with stow..."
	# stow .zshrc
	stow tmux
	stow nvim
	stow emacs

provision: ## Run the Ansible playbook
	@echo "Running Ansible provisioning..."
	ansible-playbook main.yml --ask-become-pass

help: ## Show this help menu
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'
