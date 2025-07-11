# macOS Quick Setup

A simple, customizable script for setting up your macOS development environment in
minutes.

![macOS Quick Setup](images/banner.png)

## 🚀 One-Line Installation

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/chroakPRO/macosinstall/main/install.sh)"
```

This will run the installer with a user-friendly interface that lets you select
which components to install.

## ✨ Features

This script can install and configure:

- **Shell**: Zsh with Oh-My-Zsh and custom configurations
- **Navigation**: Zoxide for smarter directory jumping
- **Text Searching**: Ripgrep for faster code searching
- **Text Editing**: Neovim with custom configuration and Cursor IDE
- **Terminal Multiplexer**: Tmux with custom configuration
- **Network Tools**: DNS lookup tools like dig
- **Development Tools**: Node.js, npm, and pnpm package manager
- **Python Environment**: Miniconda for Python development
- **Applications**: Chrome, 1Password, Magnet, and Hidden Bar

## 🛠️ How It Works

The installer provides an intuitive multi-select menu where you can choose which
components to install in a single step. The script will then automatically install
and configure all selected components for you. No need to answer multiple prompts!

## 📋 Requirements

- macOS
- Homebrew (will be installed automatically if missing)

## 🔄 Advanced Usage

The install script supports the following command-line options:

```text
--non-interactive    Run without user prompts (skips all installations)
--install-all        Install all components without prompting
--help               Show help message
```

Example advanced usage:

```bash
# Clone the repository
git clone https://github.com/chroakPRO/macosinstall.git
cd macosinstall

# Show help
./install.sh --help

# Install everything without prompts (use with caution)
./install.sh --install-all
```

If you want to install everything non-interactively from a one-liner:

```bash
/bin/bash -c "$(curl -fsSL \
  https://raw.githubusercontent.com/chroakPRO/macosinstall/main/install.sh) \
  --install-all"
```

## 🤝 Contributing

Contributions are welcome! Feel free to submit pull requests or open issues to
improve the installer.

## 📝 License

This project is open source and available under the [MIT License](LICENSE).
