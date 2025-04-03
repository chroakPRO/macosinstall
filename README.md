# macOS Quick Setup

A simple, customizable script for setting up your macOS development environment in
minutes.

![macOS Quick Setup](images/githubrepo.png)

## 🚀 One-Line Installation

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/cyberapocalypse/macosinstall/main/install.sh)"
```

This will run the installer in interactive mode, allowing you to choose which
components to install.

## ✨ Features

This script can install and configure:

- **Shell**: Zsh with Oh-My-Zsh and custom configurations
- **Navigation**: Zoxide for smarter directory jumping
- **Text Searching**: Ripgrep for faster code searching
- **Text Editing**: Neovim with custom configuration
- **Terminal Multiplexer**: Tmux with Oh-My-Tmux configuration
- **Network Tools**: DNS lookup tools like dig
- **Development Tools**: Node.js, npm, and helpful CLI tools like tldr
- **Python Environment**: Miniconda for Python development

## 🛠️ How It Works

The installer will ask for confirmation before each component installation,
allowing you to customize your setup. All components are optional and can be
skipped based on your preferences.

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
git clone https://github.com/cyberapocalypse/macosinstall.git
cd macosinstall

# Show help
./install.sh --help

# Install everything without prompts (use with caution)
./install.sh --install-all
```

If you want to install everything non-interactively from a one-liner:

```bash
/bin/bash -c "$(curl -fsSL \
  https://raw.githubusercontent.com/cyberapocalypse/macosinstall/main/install.sh) \
  --install-all"
```

## 🤝 Contributing

Contributions are welcome! Feel free to submit pull requests or open issues to
improve the installer.

## 📝 License

This project is open source and available under the [MIT License](LICENSE).
