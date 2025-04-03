#!/bin/bash

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Parse command line arguments
NON_INTERACTIVE=false
INSTALL_ALL=false
SHOW_HELP=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --non-interactive)
      NON_INTERACTIVE=true
      shift
      ;;
    --install-all)
      INSTALL_ALL=true
      NON_INTERACTIVE=true
      shift
      ;;
    --help)
      SHOW_HELP=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Display help if requested
if [[ $SHOW_HELP == true ]]; then
  echo "macOS Development Environment Installer"
  echo ""
  echo "Usage: ./install.sh [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  --non-interactive    Run without user prompts (skips all installations)"
  echo "  --install-all        Install all components without prompting"
  echo "  --help               Show this help message"
  echo ""
  exit 0
fi

# Ensure Homebrew is installed
if ! command_exists brew; then
  echo "Homebrew is not installed. Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  
  # Add Homebrew to PATH for ARM Macs if needed
  if [[ $(uname -m) == 'arm64' ]]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
fi

# Step 1: Install zsh prompt and download config
if [[ $NON_INTERACTIVE == true ]]; then
  install_zsh=$([[ $INSTALL_ALL == true ]] && echo "y" || echo "n")
else
  read -p "Do you want to install zsh and download the config? (y/n): " install_zsh
fi

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
if [[ $NON_INTERACTIVE == true ]]; then
  install_ripgrep=$([[ $INSTALL_ALL == true ]] && echo "y" || echo "n")
else
  read -p "Do you want to install ripgrep? (y/n): " install_ripgrep
fi

if [[ $install_ripgrep == "y" || $install_ripgrep == "Y" ]]; then
  if ! command_exists rg; then
    echo "Installing ripgrep..."
    brew update && brew install ripgrep
  else
    echo "ripgrep is already installed"
  fi
fi

# Step 3: Install Neovim, Lua 5.4, and LuaRocks, then download config
if [[ $NON_INTERACTIVE == true ]]; then
  install_nvim=$([[ $INSTALL_ALL == true ]] && echo "y" || echo "n")
else
  read -p "Do you want to install Neovim and download the config? (y/n): " install_nvim
fi

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
if [[ $NON_INTERACTIVE == true ]]; then
  install_dig=$([[ $INSTALL_ALL == true ]] && echo "y" || echo "n")
else
  read -p "Do you want to check if 'dig' is installed and install if necessary? (y/n): " install_dig
fi

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
if [[ $NON_INTERACTIVE == true ]]; then
  install_zoxide=$([[ $INSTALL_ALL == true ]] && echo "y" || echo "n")
else
  read -p "Do you want to install zoxide? (y/n): " install_zoxide
fi

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
if [[ $NON_INTERACTIVE == true ]]; then
  install_tmux=$([[ $INSTALL_ALL == true ]] && echo "y" || echo "n")
else
  read -p "Do you want to install tmux and oh-my-tmux? (y/n): " install_tmux
fi

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

# Step 7: Install Node.js, npm, and pnpm
if [[ $NON_INTERACTIVE == true ]]; then
  install_node=$([[ $INSTALL_ALL == true ]] && echo "y" || echo "n")
else
  read -p "Do you want to install Node.js, npm, and pnpm? (y/n): " install_node
fi

if [[ $install_node == "y" || $install_node == "Y" ]]; then
  if ! command_exists node; then
    echo "Installing Node.js and npm..."
    brew update
    brew install node
  else
    echo "Node.js is already installed"
  fi

  # Install pnpm
  echo "Installing pnpm..."
  npm install -g pnpm
fi

# Step 8: Install Miniconda (auto-init conda + auto_activate_base)
if [[ $NON_INTERACTIVE == true ]]; then
  install_miniconda=$([[ $INSTALL_ALL == true ]] && echo "y" || echo "n")
else
  read -p "Do you want to install Miniconda? (y/n): " install_miniconda
fi

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
