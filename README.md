# Alex's Dotfiles

Personal dotfiles managed with [chezmoi](https://chezmoi.io) for consistent development environment across machines.

## Features

### Shell Configuration
- **Zsh** with Pure prompt theme and Antigen plugin manager
- **Bash** with custom Git-aware prompt
- Vi mode editing in both shells
- Extensive aliases for Git, Kubernetes, and daily tasks
- History optimization with fzf integration
- Zsh plugins: syntax highlighting, autosuggestions, completions

### Development Tools
- **Neovim** configuration with modern plugins
- **Tmux** with powerline, session persistence
- **mise** for language version management
- **GPG** and SSH key management
- **Kubernetes** tools (kubectl, kubectx, kubens, flux)

### Applications
- Git configuration
- Terminal preferences
- Development environment variables

## Quick Start

### Prerequisites
- Git
- curl
- zsh (optional, will be set as default shell)

### Installation
```bash
# Install via chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply https://github.com/alexbenisch/dotfiles

# Or manually
git clone https://github.com/alexbenisch/dotfiles.git ~/.local/share/dotfiles
cd ~/.local/share/dotfiles
./setup
```

## Structure

```
dotfiles/
├── dot_bashrc                    # Bash configuration
├── dot_zshrc                     # Zsh configuration  
├── dot_zprofile                  # Zsh profile
├── dot_config/
│   ├── mise/
│   │   └── config.toml          # Language version manager
│   ├── nvim/                    # Neovim configuration
│   │   ├── lua/config/
│   │   └── lua/plugins/
│   └── tmux/
│       ├── tmux.conf           # Tmux configuration
│       └── plugins/            # Tmux plugin manager
├── setup                        # Installation script
└── README.md                    # This file
```

## Key Features

### Shell (Zsh)
- **Pure prompt** - Minimal, fast, customizable
- **Vi mode** - Modal editing in command line
- **History** - 100k entries, shared between sessions
- **Completion** - Enhanced with fzf integration
- **Aliases** - Optimized for Git, Kubernetes, development

### Development Environment
- **Editor**: Neovim as default, Vim for SSH
- **Terminal**: tmux-256color support
- **Version Management**: mise for languages/tools
- **PATH**: Organized with user bins, scripts
- **GPG**: Configured for SSH authentication

### Key Aliases
```bash
# File operations
ls -> lsd (if available)
cat -> bat (if available)

# Git
gs = git status
gp = git pull  
lg = lazygit

# Kubernetes
k = kubectl
kgp = kubectl get pods
kc = kubectx
kn = kubens
fgk = flux get kustomizations

# DevPod
ds = devpod ssh

# Password management
pc = pass show -c
```

### Tmux Configuration
- **Plugin Manager**: TPM with auto-installation
- **Session Persistence**: resurrect + continuum
- **Powerline**: Status bar with system info
- **Mouse Support**: Toggle with prefix + m
- **256 Color**: Full color terminal support

## Customization

### Environment Variables
Key variables defined in `dot_zshrc`:
- `REPOS`: ~/repos (project directory)
- `GITUSER`: alexbenisch
- `GHREPOS`: GitHub repositories path
- `SCRIPTS`: Dotfiles scripts directory
- `EDITOR`: nvim
- `BROWSER`: google-chrome-stable

### Tool Integration
- **fzf**: Fuzzy finder with Ctrl+R history search
- **mise**: Automatic activation for language versions
- **GPG**: Agent integration for SSH keys
- **kubectl**: Tab completion enabled
- **flux**: Kubernetes GitOps completion

## Maintenance

### Updating Dotfiles
```bash
# Pull latest changes
chezmoi update

# Or manually
cd ~/.local/share/dotfiles
git pull
./setup
```

### Adding New Configurations
```bash
# Add new dotfile
chezmoi add ~/.newconfig

# Edit existing
chezmoi edit ~/.zshrc

# Apply changes
chezmoi apply
```

## Dependencies

### Required
- **zsh**: Shell (will be set as default)
- **git**: Version control
- **curl**: Downloads and installations
- **antigen**: Zsh plugin manager (auto-installed by setup script)

### Optional (Enhanced Experience)
- **fzf**: Fuzzy finding and history search
- **bat**: Better cat with syntax highlighting
- **lsd**: Better ls with icons and colors
- **neovim**: Modern vim editor
- **tmux**: Terminal multiplexer
- **mise**: Language version management
- **kubectl**: Kubernetes CLI
- **flux**: GitOps toolkit

### Tmux Plugins (Auto-installed)
- tmux-plugins/tpm
- tmux-plugins/tmux-sensible
- erikw/tmux-powerline
- tmux-plugins/tmux-resurrect
- tmux-plugins/tmux-continuum

### Zsh Plugins (Auto-installed via Antigen)
- git, command-not-found, docker, kubectl (from oh-my-zsh)
- zsh-users/zsh-syntax-highlighting
- zsh-users/zsh-autosuggestions
- zsh-users/zsh-completions
- unixorn/fzf-zsh-plugin

## Notes

- Setup script will change default shell to zsh
- **Antigen** plugin manager is installed to `~/.antigen/` by setup script
- Pure prompt theme is cloned to `~/.zsh/pure`
- Zsh plugins are auto-installed by Antigen on first shell launch
- **Important**: `antigen bundle` without a repository path defaults to oh-my-zsh plugins
- **Automatic backup**: Existing `.zshrc`, `.zprofile`, `.bashrc` are backed up as `YYYY-MM-DD_filename_backup`
- Shell configs are automatically applied via chezmoi during setup
- Tmux plugins are auto-installed on first run
- GPG agent is configured for SSH key management
- mise is used for language/tool version management

## Troubleshooting

### Zsh Configuration Issues

**Error: `~/.antigen/antigen.zsh` not found**
- Antigen was missing from the setup process
- Fixed in latest version: setup script now installs Antigen automatically
- Manual fix: `mkdir -p ~/.antigen && curl -L git.io/antigen > ~/.antigen/antigen.zsh`
- Then run: `source ~/.zshrc` to install all plugins

**Understanding Antigen Plugin Sources**
- `antigen bundle <plugin>` → pulls from oh-my-zsh (e.g., `git`, `docker`)
- `antigen bundle <user>/<repo>` → pulls from GitHub (e.g., `zsh-users/zsh-syntax-highlighting`)
- oh-my-zsh framework is installed automatically as a dependency for oh-my-zsh plugins

**Error: `tee: /completions/_docker: No such file or directory`**
- The `~/.zfunc` directory for zsh completions is missing
- Fixed in latest version: setup script now creates `~/.zfunc` automatically
- Manual fix: `mkdir -p ~/.zfunc`
- Regenerate completions: `docker completion zsh > ~/.zfunc/_docker` (if docker is installed)

## License

MIT License - Feel free to use and modify as needed.