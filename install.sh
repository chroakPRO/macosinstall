#!/bin/bash

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Ensure Homebrew is installed
if ! command_exists brew; then
  echo "Homebrew is not installed. Please install Homebrew from https://brew.sh/ and run this script again."
  exit 1
fi

# Step 1: Install zsh prompt and download config
read -p "Do you want to install zsh and download the config? (y/n): " install_zsh
if [[ $install_zsh == "y" || $install_zsh == "Y" ]]; then
  if ! command_exists zsh; then
    echo "Installing zsh..."
    brew install zsh
  else
    echo "zsh is already installed"
  fi

  # Set zsh as default shell
  chsh -s "$(which zsh)"

  # Install oh-my-zsh
  echo "Installing oh-my-zsh..."
  RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

  # Download zsh config
  echo "Downloading zsh config..."
  rm -rf "$HOME/.zshconfig"
  git clone https://github.com/chroakPRO/zshdot "$HOME/.zshconfig"
fi

# Step 2: Install ripgrep
read -p "Do you want to install ripgrep? (y/n): " install_ripgrep
if [[ $install_ripgrep == "y" || $install_ripgrep == "Y" ]]; then
  if ! command_exists rg; then
    echo "Installing ripgrep..."
    brew update && brew install ripgrep
  else
    echo "ripgrep is already installed"
  fi
fi

# Step 3: Install Neovim, Lua 5.4, and LuaRocks, then download config
read -p "Do you want to install Neovim and download the config? (y/n): " install_nvim
if [[ $install_nvim == "y" || $install_nvim == "Y" ]]; then

  # Install Lua 5.4 and LuaRocks
  if ! command_exists lua; then
    echo "Installing Lua 5.4 and LuaRocks..."
    brew update
    brew install lua@5.4
    brew install luarocks
  else
    echo "Lua is already installed"
  fi

  if ! command_exists nvim; then
    echo "Installing Neovim..."
    brew update
    brew install neovim
  else
    echo "Neovim is already installed"
  fi

  # Download Neovim config
  echo "Downloading Neovim config..."
  rm -rf "$HOME/.config/nvim"
  git clone https://github.com/chroakPRO/nvimdot "$HOME/.config/nvim"
fi

# Step 4: Check if 'dig' exists, otherwise install
read -p "Do you want to check if 'dig' is installed and install if necessary? (y/n): " install_dig
if [[ $install_dig == "y" || $install_dig == "Y" ]]; then
  if ! command_exists dig; then
    echo "Installing dig..."
    brew update
    brew install bind
  else
    echo "dig is already installed"
  fi
fi

# Step 5: Install zoxide
read -p "Do you want to install zoxide? (y/n): " install_zoxide
if [[ $install_zoxide == "y" || $install_zoxide == "Y" ]]; then
  if ! command_exists zoxide; then
    echo "Installing zoxide..."
    brew update
    brew install zoxide
  else
    echo "zoxide is already installed"
  fi
fi

# Step 6: Install tmux and oh-my-tmux
read -p "Do you want to install tmux and oh-my-tmux? (y/n): " install_tmux
if [[ $install_tmux == "y" || $install_tmux == "Y" ]]; then
  if ! command_exists tmux; then
    echo "Installing tmux..."
    brew update
    brew install tmux
  else
    echo "tmux is already installed"
  fi

  # Install oh-my-tmux
  echo "Installing oh-my-tmux..."
  git clone https://github.com/chroakPRO/tmuxdot.git "$HOME/.tmux"
  cp "$HOME/.tmux/.tmux.conf" "$HOME/.tmux.conf"
fi

# Step 7: Install Node.js, npm, and tldr
read -p "Do you want to install Node.js, npm, and tldr? (y/n): " install_node
if [[ $install_node == "y" || $install_node == "Y" ]]; then
  if ! command_exists node; then
    echo "Installing Node.js and npm..."
    brew update
    brew install node
  else
    echo "Node.js is already installed"
  fi

  # Install tldr
  echo "Installing tldr..."
  npm install -g tldr
fi

# Step 8: Install Miniconda (auto-init conda + auto_activate_base)
read -p "Do you want to install Miniconda? (y/n): " install_miniconda
if [[ $install_miniconda == "y" || $install_miniconda == "Y" ]]; then
  if ! command_exists conda; then
    echo "Installing Miniconda..."
    # Download the latest Miniconda installer for macOS ARM
    curl -o "$HOME/miniconda.sh" https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh
    # Run the installer silently (-b) and install to ~/miniconda
    bash "$HOME/miniconda.sh" -b -p "$HOME/miniconda"
    # Remove the installer
    rm "$HOME/miniconda.sh"

    echo "Initializing conda for bash and zsh..."
    "$HOME/miniconda/bin/conda" init bash
    "$HOME/miniconda/bin/conda" init zsh

    echo "Enabling auto_activate_base..."
    "$HOME/miniconda/bin/conda" config --set auto_activate_base true

    echo "Miniconda installation complete."
    echo "Please open a new terminal or run 'source ~/.bashrc' or 'source ~/.zshrc' to start using conda."
  else
    echo "A conda-based environment is already installed on this system."
  fi
fi

# Done
echo "Setup complete!"
