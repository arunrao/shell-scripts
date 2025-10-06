.PHONY: help install uninstall test check-deps list update clean

# Default target
.DEFAULT_GOAL := help

# Installation directory (user's local bin)
INSTALL_DIR := $(HOME)/.local/bin
BIN_DIR := $(CURDIR)/bin
LIB_DIR := $(CURDIR)/lib

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m # No Color

help: ## Show this help message
	@echo "$(BLUE)Shell Scripts Library - Makefile Commands$(NC)"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "Quick start: make install"

install: ## Install scripts to ~/.local/bin (recommended)
	@echo "$(BLUE)Installing shell scripts...$(NC)"
	@mkdir -p $(INSTALL_DIR)
	@for script in $(BIN_DIR)/*; do \
		script_name=$$(basename $$script); \
		ln -sf $$script $(INSTALL_DIR)/$$script_name; \
		echo "  $(GREEN)✓$(NC) Installed $$script_name"; \
	done
	@echo ""
	@echo "$(GREEN)✓ Installation complete!$(NC)"
	@echo ""
	@echo "$(YELLOW)Next steps:$(NC)"
	@echo "1. Ensure $(INSTALL_DIR) is in your PATH"
	@echo "   Add to ~/.zshrc or ~/.bashrc:"
	@echo "   export PATH=\"\$$HOME/.local/bin:\$$PATH\""
	@echo ""
	@echo "2. Reload your shell:"
	@echo "   source ~/.zshrc  # or ~/.bashrc"
	@echo ""
	@echo "3. Test it works:"
	@echo "   trash --help"
	@echo ""
	@$(MAKE) --no-print-directory check-path

install-system: ## Install scripts to /usr/local/bin (system-wide, requires sudo)
	@echo "$(BLUE)Installing scripts system-wide...$(NC)"
	@echo "$(YELLOW)This requires sudo privileges$(NC)"
	@for script in $(BIN_DIR)/*; do \
		script_name=$$(basename $$script); \
		sudo cp $$script /usr/local/bin/$$script_name; \
		sudo chmod +x /usr/local/bin/$$script_name; \
		echo "  $(GREEN)✓$(NC) Installed $$script_name to /usr/local/bin"; \
	done
	@echo ""
	@echo "$(GREEN)✓ System-wide installation complete!$(NC)"

uninstall: ## Remove installed scripts from ~/.local/bin
	@echo "$(BLUE)Uninstalling shell scripts...$(NC)"
	@for script in $(BIN_DIR)/*; do \
		script_name=$$(basename $$script); \
		if [ -L $(INSTALL_DIR)/$$script_name ]; then \
			rm $(INSTALL_DIR)/$$script_name; \
			echo "  $(GREEN)✓$(NC) Removed $$script_name"; \
		fi; \
	done
	@echo ""
	@echo "$(GREEN)✓ Uninstallation complete!$(NC)"

uninstall-system: ## Remove scripts from /usr/local/bin (requires sudo)
	@echo "$(BLUE)Uninstalling system-wide scripts...$(NC)"
	@echo "$(YELLOW)This requires sudo privileges$(NC)"
	@for script in $(BIN_DIR)/*; do \
		script_name=$$(basename $$script); \
		if [ -f /usr/local/bin/$$script_name ]; then \
			sudo rm /usr/local/bin/$$script_name; \
			echo "  $(GREEN)✓$(NC) Removed $$script_name"; \
		fi; \
	done
	@echo ""
	@echo "$(GREEN)✓ System-wide uninstallation complete!$(NC)"

test: ## Test that scripts are accessible and executable
	@echo "$(BLUE)Testing installation...$(NC)"
	@echo ""
	@failed=0; \
	for script in $(BIN_DIR)/*; do \
		script_name=$$(basename $$script); \
		if command -v $$script_name >/dev/null 2>&1; then \
			echo "  $(GREEN)✓$(NC) $$script_name"; \
		else \
			echo "  $(RED)✗$(NC) $$script_name not found in PATH"; \
			failed=$$((failed + 1)); \
		fi; \
	done; \
	echo ""; \
	if [ $$failed -eq 0 ]; then \
		echo "$(GREEN)✓ All scripts are accessible!$(NC)"; \
	else \
		echo "$(RED)✗ $$failed script(s) not found in PATH$(NC)"; \
		echo "$(YELLOW)Did you add ~/.local/bin to your PATH?$(NC)"; \
		exit 1; \
	fi

check-deps: ## Check for optional dependencies
	@echo "$(BLUE)Checking optional dependencies...$(NC)"
	@echo ""
	@echo "$(YELLOW)Core functionality (required):$(NC)"
	@for cmd in bash grep sed awk find curl; do \
		if command -v $$cmd >/dev/null 2>&1; then \
			echo "  $(GREEN)✓$(NC) $$cmd"; \
		else \
			echo "  $(RED)✗$(NC) $$cmd (required)"; \
		fi; \
	done
	@echo ""
	@echo "$(YELLOW)Enhanced functionality (optional):$(NC)"
	@for cmd in fzf jq yq ripgrep gsed; do \
		if command -v $$cmd >/dev/null 2>&1; then \
			echo "  $(GREEN)✓$(NC) $$cmd"; \
		else \
			echo "  $(YELLOW)○$(NC) $$cmd (optional - install with: brew install $$cmd)"; \
		fi; \
	done
	@echo ""
	@echo "$(YELLOW)Development tools (optional):$(NC)"
	@for cmd in docker kubectl aws; do \
		if command -v $$cmd >/dev/null 2>&1; then \
			echo "  $(GREEN)✓$(NC) $$cmd"; \
		else \
			echo "  $(YELLOW)○$(NC) $$cmd (optional)"; \
		fi; \
	done

list: ## List all available scripts
	@echo "$(BLUE)Available scripts (37 total):$(NC)"
	@echo ""
	@ls -1 $(BIN_DIR) | pr -t -3 | sed 's/^/  /'
	@echo ""
	@echo "Run 'make help' to see installation commands"
	@echo "Run '<script-name> --help' for usage information"

update: ## Update scripts from repository (git pull)
	@echo "$(BLUE)Updating scripts from repository...$(NC)"
	@git pull
	@echo ""
	@echo "$(GREEN)✓ Update complete!$(NC)"
	@echo ""
	@echo "Run 'make install' to update symlinks if needed"

clean: ## Remove temporary files and caches
	@echo "$(BLUE)Cleaning temporary files...$(NC)"
	@find . -name "*.bak" -delete
	@find . -name ".DS_Store" -delete
	@find . -name "*.swp" -delete
	@echo "$(GREEN)✓ Clean complete!$(NC)"

check-path: ## Check if install directory is in PATH
	@if echo $$PATH | grep -q "$(INSTALL_DIR)"; then \
		echo "$(GREEN)✓ $(INSTALL_DIR) is in your PATH$(NC)"; \
		echo ""; \
		echo "$(YELLOW)Checking PATH priority...$(NC)"; \
		if echo $$PATH | grep -oE '[^:]+' | head -20 | grep -n "$(INSTALL_DIR)" | grep -q "^[1-5]:"; then \
			echo "$(GREEN)✓ $(INSTALL_DIR) has good priority in PATH$(NC)"; \
		else \
			echo "$(YELLOW)⚠ $(INSTALL_DIR) might be too late in PATH$(NC)"; \
			echo "  Some system commands may override custom scripts"; \
			echo "  Ensure $(INSTALL_DIR) comes BEFORE /usr/bin"; \
		fi; \
	else \
		echo "$(YELLOW)⚠ $(INSTALL_DIR) is NOT in your PATH$(NC)"; \
		echo ""; \
		echo "Add this to your ~/.zshrc or ~/.bashrc:"; \
		echo "  export PATH=\"\$$HOME/.local/bin:\$$PATH\""; \
		echo ""; \
		echo "Then reload your shell:"; \
		echo "  source ~/.zshrc  # or ~/.bashrc"; \
	fi

demo: ## Run a quick demo of popular scripts
	@echo "$(BLUE)Shell Scripts Library - Quick Demo$(NC)"
	@echo ""
	@echo "$(YELLOW)1. trash - Safe file deletion$(NC)"
	@echo "   trash --help | head -10"
	@echo ""
	@echo "$(YELLOW)2. killport - Kill process on port$(NC)"
	@echo "   killport --help | head -10"
	@echo ""
	@echo "$(YELLOW)3. timer - Countdown timer$(NC)"
	@echo "   timer --help | head -10"
	@echo ""
	@echo "Run 'make list' to see all 37 scripts"
	@echo "Run '<script-name> --help' for detailed usage"

info: ## Show project information
	@echo "$(BLUE)Shell Scripts Library$(NC)"
	@echo ""
	@echo "Version:      1.0.0"
	@echo "Scripts:      37 utilities"
	@echo "Location:     $(CURDIR)"
	@echo "Install dir:  $(INSTALL_DIR)"
	@echo ""
	@echo "Categories:"
	@echo "  • Clipboard (2)"
	@echo "  • Filesystem & Dev (7)"
	@echo "  • File Safety (2)"
	@echo "  • Networking & Ops (6)"
	@echo "  • Git (3)"
	@echo "  • System Info (2)"
	@echo "  • Docker & Kubernetes (4)"
	@echo "  • Cloud (1)"
	@echo "  • Text & Data (5)"
	@echo "  • Productivity (2)"
	@echo "  • macOS Specific (3)"
	@echo ""
	@echo "Run 'make help' for available commands"
