# Shell Scripts Library

A collection of 37 cross-platform shell utilities for macOS and Linux users.

## Features

- **Cross-platform**: Works on both macOS and Linux with smart fallbacks
- **Consistent**: All scripts use shared `lib/common.sh` for unified UX
- **Modern**: Strict error handling, colored output, helpful usage docs
- **Modular**: Easy to extend and customize
- **Safe**: Confirmation prompts for destructive operations

## Installation

### Quick Install (Recommended)

```bash
# 1. Clone the repository
git clone https://github.com/yourusername/shell-scripts.git
cd shell-scripts

# 2. Install (one command!)
make install

# 3. Add to PATH if needed (Makefile will tell you if required)
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# 4. Verify installation
make test
```

That's it! The Makefile handles all the symlinks automatically.

### Other Installation Options

```bash
make install-system   # Install to /usr/local/bin (system-wide, needs sudo)
make uninstall        # Remove from ~/.local/bin
make help            # See all available commands
```

## Quick Start

```bash
# Clipboard operations
echo "hello" | xcopy        # Copy to clipboard
xpaste                      # Paste from clipboard

# File operations
mkcd myproject              # Make dir and cd into it
trash old-file.txt          # Move to Trash (safe delete)
backup config.txt           # Timestamped backup with checksum

# Development helpers
killport 3000               # Kill process on port 3000
serve                       # Start HTTP server (port 8000)
ff "*.js"                   # Fuzzy find files

# System info
sysinfo                     # System overview
ports                       # List listening ports

# Git helpers
gdirty                      # Show repos with changes
gpr 123                     # Checkout PR #123
```

## Scripts Overview

### Clipboard (2)
- `xcopy` - Copy stdin/file to clipboard (cross-platform)
- `xpaste` - Paste clipboard to stdout

### Filesystem & Dev (7)
- `backup` - Safe timestamped backup with checksums
- `bcopy` - Batch copy files with smart backup
- `cdf` - (macOS) cd to current Finder directory
- `ff` - Fuzzy find files (fzf/ripgrep fallback)
- `gsed` - Portable sed wrapper (prefers GNU sed)
- `mkcd` - Make directory and cd into it
- `serve` - Quick static HTTP server (python/php/busybox)

### File Safety (2)
- `trash` - Move files to Trash instead of rm (recoverable!)
- `killport` - Kill process listening on specific port

### Networking & Ops (6)
- `ipinfo` - Show local/public IPs, routes, DNS
- `ports` - List listening ports (ss/lsof/netstat)
- `probe` - Curl URL with timing, TLS info, retries
- `pullrsync` - Safe rsync pull with dry-run preview
- `pushrsync` - Safe rsync push with dry-run preview
- `wake` - Wake-on-LAN magic packet sender

### Git (3)
- `gclean-branches` - Prune merged branches safely
- `gdirty` - Show uncommitted files across git repos
- `gpr` - Fetch and checkout GitHub PR by number

### System Info (2)
- `sysinfo` - CPU/memory/disk/battery info with smart fallbacks
- `upto` - System uptime and boot history

### Docker & Kubernetes (4)
- `drmorphans` - Remove orphaned Docker images
- `dstopall` - Stop all Docker containers
- `kctx` - kubectl context switcher (with fzf)
- `kns` - kubectl namespace switcher (with fzf)

### Cloud (1)
- `aws-whoami` - Show current AWS identity and config

### Text & Data (5)
- `jsonfmt` - Pretty-print/validate JSON (jq/python)
- `json2yaml` - Convert JSON to YAML
- `randpw` - Generate random passwords/passphrases
- `uniqs` - Show unique lines with counts (portable)
- `yaml2json` - Convert YAML to JSON

### Productivity (2)
- `td` - Tiny todo list manager (plaintext)
- `timer` - CLI countdown timer with visual progress

### macOS Specific (3)
- `darkmode` - Toggle/read macOS appearance mode
- `killdock` - Restart Dock, Finder, SystemUIServer
- `showhidden` - Toggle Finder hidden files visibility

## Highlights

### 🔥 Most Useful for Mac Developers

**trash** - Never accidentally `rm -rf` something important again
```bash
trash old-project/          # Recoverable from Finder Trash
trash --list                # See what's in Trash
trash --empty               # Empty trash with confirmation
```

**killport** - Fix "port already in use" instantly
```bash
killport 3000               # Kill whatever's using port 3000
killport 8080 --force       # Force kill without confirmation
killport --list             # Show all listening ports
```

**xcopy/xpaste** - Cross-platform clipboard (works on Linux too)
```bash
cat file.txt | xcopy        # Copy file to clipboard
xpaste > output.txt         # Paste from clipboard
```

**timer** - Visual countdown with notification
```bash
timer 5m                    # 5 minute timer
timer 30s "Coffee ready"    # With custom message
```

**gdirty** - Find repos with uncommitted changes
```bash
gdirty ~/projects           # Check all projects
```

## Development

### Adding New Scripts

All scripts follow this pattern:

1. Add script to `bin/` without file extension
2. Start with `#!/usr/bin/env bash` and `set -Eeuo pipefail`
3. Source `lib/common.sh` for shared functions
4. Include `show_usage()` function with `--help` support
5. Use common.sh helpers: `log_info()`, `log_error()`, `confirm()`, `die()`, etc.
6. Make executable: `chmod +x bin/yourscript`

### Script Template

```bash
#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

show_usage() {
    cat <<EOF
Usage: myscript [options]
Description of what it does.
EOF
}

main() {
    # Your logic here
    log_info "Starting..."
    # Use: log_success, log_warn, log_error, die
}

main "$@"
```

## Project Structure

```
.
├── bin/                  # 37 executable scripts
├── lib/
│   └── common.sh        # Shared utilities library
├── LICENSE              # MIT License
└── README.md           # This file
```

### Common Library (`lib/common.sh`)

Provides shared functions used by all scripts:

**OS Detection**: `is_mac()`, `is_linux()`, `is_wsl()`, `get_os()`
**Logging**: `log_info()`, `log_success()`, `log_warn()`, `log_error()`, `log_debug()`
**Error Handling**: `die()`, `need_cmd()`, `have_cmd()`
**User Interaction**: `confirm()` - smart yes/no prompts
**Retry Logic**: `retry()` - exponential backoff
**Clipboard**: `get_clipboard_cmd()` - cross-platform clipboard
**File Utils**: `get_absolute_path()`, `ensure_dir()`
**String Utils**: `trim()`, `lowercase()`, `uppercase()`
**Validation**: `is_integer()`, `is_valid_ip()`

## Requirements

### Required
- **Bash 4.0+** (macOS 10.15+ includes Bash 3.2, consider upgrading via Homebrew)
- Standard Unix utilities: `grep`, `sed`, `awk`, `find`, `curl`

### Optional (enhances functionality)

**For Better Experience:**
- `fzf` - Interactive fuzzy finding (`kctx`, `kns`, `ff`)
- `jq` - JSON processing (`jsonfmt`)
- `yq` - YAML processing (`yaml2json`, `json2yaml`)
- `ripgrep` - Fast file searching (`ff`)

**For Linux Clipboard:**
- `xclip` or `xsel` (X11) / `wl-clipboard` (Wayland)

**For Development:**
- `docker` - Container scripts (`dstopall`, `drmorphans`)
- `kubectl` - Kubernetes scripts (`kctx`, `kns`)
- `aws-cli` - AWS scripts (`aws-whoami`)

Most scripts work with built-in macOS/Linux tools and gracefully fall back when optional dependencies are missing.

## Makefile Commands

The included Makefile makes management easy:

```bash
make help            # Show all available commands
make install         # Install to ~/.local/bin (recommended)
make test            # Verify all scripts are accessible
make check-deps      # Check for optional dependencies
make list            # List all 37 scripts
make update          # Pull latest changes from git
make uninstall       # Remove installed scripts
make info            # Show project information
```

## Usage Tips

- All scripts support `--help` flag for detailed usage
- Use `TAB` completion after installing (if shell completion is set up)
- Set `DEBUG=1` environment variable for verbose output
- Scripts respect `.gitignore` when searching files

## Contributing

Contributions welcome! Please:

1. Follow the script template pattern (see Development section)
2. Use `lib/common.sh` functions for consistency
3. Add `--help` documentation
4. Test on both macOS and Linux if possible
5. Use `shellcheck` to validate scripts

## License

MIT License - see LICENSE file for details

## Author

Created by [Arun Rao](https://github.com/arunrao)
