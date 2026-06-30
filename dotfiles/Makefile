# Wesley's dotfiles Makefile — stow-driven, omerxx-style.
# Run `make help` for the full list of targets.

DOTFILES_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
STOW        ?= stow
TARGET      ?= $(HOME)
PACKAGES     = config home

.PHONY: help stow unstow restow adopt bootstrap clean status

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

stow: ## Stow all packages into $$HOME
	$(STOW) --target=$(TARGET) --dir=$(DOTFILES_DIR) $(PACKAGES)

unstow: ## Remove all stow symlinks from $$HOME
	$(STOW) --target=$(TARGET) --dir=$(DOTFILES_DIR) --delete $(PACKAGES)

restow: ## Re-stow (handles file moves cleanly)
	$(STOW) --target=$(TARGET) --dir=$(DOTFILES_DIR) --restow $(PACKAGES)

adopt: ## Turn existing real files into symlinks (one-way migration)
	$(STOW) --target=$(TARGET) --dir=$(DOTFILES_DIR) --adopt $(PACKAGES)

bootstrap: restow ## Stow + remind user to run nrs
	@echo ""
	@echo "==> Dotfiles stowed to $(TARGET)"
	@echo "==> Next: run 'nrs' inside WSL to apply Nix-managed parts."

clean: ## Remove orphan symlinks left behind after package removal
	$(STOW) --target=$(TARGET) --dir=$(DOTFILES_DIR) --restow $(PACKAGES)

status: ## Show what's currently symlinked
	@for pkg in $(PACKAGES); do \
		echo "==> $$pkg"; \
		ls -la $(DOTFILES_DIR)$$pkg 2>/dev/null | head -10 || true; \
		echo ""; \
	done