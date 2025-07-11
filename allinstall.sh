#!/bin/bash
set -euo pipefail

# Terminal colors (same as install.sh)
CYAN=$'\e[36m'
GREEN=$'\e[32m'
YELLOW=$'\e[33m'
BLUE=$'\e[34m'
GRAY=$'\e[90m'
BOLD=$'\e[1m'
RED=$'\e[31m'
RESET=$'\e[0m'

# Print functions (same as install.sh)
print() { local color=$1; local text=$2; printf "%b%s%b\n" "${color}" "${text}" "${RESET}"; }
print_cmd() { printf "%b$ %s%b\n" "${GRAY}" "$1" "${RESET}"; }
print_header() { printf "\n%b%s%b\n" "${BOLD}${BLUE}" "$1" "${RESET}"; printf "%b%s%b\n" "${BLUE}" "$(printf '─%.0s' $(seq 1 ${#1}))" "${RESET}"; }
print_success() { printf "%b✓ %s%b\n" "${GREEN}" "$1" "${RESET}"; }
print_info() { printf "%b• %s%b\n" "${CYAN}" "$1" "${RESET}"; }
print_warning() { printf "%b! %s%b\n" "${YELLOW}" "$1" "${RESET}"; }
print_error() { printf "%b✗ %s%b\n" "${RED}" "$1" "${RESET}" >&2; }

# Welcome message
show_welcome() {
  clear
  printf "\n%b" "${BOLD}${CYAN}"
  cat << "EOF"
┌────────────────────────────────────────────────┐
│                                                │
│           Universal Quick Setup                │
│    [macOS, Ubuntu, Arch developer tool]        │
│                                                │
└────────────────────────────────────────────────┘
EOF
  printf "%b\n\n" "${RESET}"
  print_info "Setup your developer environment with a single command"
  printf "\n"
}

# Command exists
command_exists() { command -v "$1" >/dev/null 2>&1; }

# Detect OS and package manager
OS="unknown"
PKG=""
OS_NAME=""

if [[ "$(uname)" == "Darwin" ]]; then
  OS="macos"
  PKG="brew"
  OS_NAME="macOS"
elif [[ -f /etc/os-release ]]; then
  . /etc/os-release
  case "$ID" in
    ubuntu|debian)
      OS="ubuntu"
      PKG="apt"
      OS_NAME="Ubuntu/Debian"
      ;;
    arch)
      OS="arch"
      PKG="pacman"
      OS_NAME="Arch Linux"
      ;;
    *)
      print_error "Unsupported Linux distribution: $ID"
      exit 1
      ;;
  esac
else
  print_error "Unsupported OS: $(uname)"
  exit 1
fi

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
      print_error "Unknown option: $1"
      exit 1
      ;;
  esac
done

if [[ $SHOW_HELP == true ]]; then
  print_header "USAGE"
  print "${BOLD}" "  ./allinstall.sh [OPTIONS]"
  print_header "OPTIONS"
  print_info "  --non-interactive    Run without prompts"
  print_info "  --install-all        Install all components without prompting"
  print_info "  --help               Show this help message"
  exit 0
fi

if [[ $NON_INTERACTIVE == false ]]; then
  show_welcome
fi

# Component definitions
COMPONENT_NAMES=("zsh" "ripgrep" "neovim" "cursor" "dig" "zoxide" "tmux" "node" "miniconda" "apps" "all")
COMPONENT_DESCRIPTIONS=(
  "Zsh shell with Oh-My-Zsh"
  "Fast text search tool"
  "Advanced text editor"
  "AI-powered code editor"
  "DNS lookup tools"
  "Smarter directory navigation"
  "Terminal multiplexer"
  "Node.js and npm"
  "Python environment manager"
  "Chrome, 1Password, Magnet, Hidden Bar (macOS only)"
  "Install all components"
)

SHELL_COMPONENTS=("zsh")
EDITOR_COMPONENTS=("ripgrep" "neovim" "cursor")
UTIL_COMPONENTS=("dig" "zoxide" "tmux")
DEV_COMPONENTS=("node" "miniconda")
APP_COMPONENTS=("apps")
ALL_COMPONENTS=(
  "${SHELL_COMPONENTS[@]}"
  "${EDITOR_COMPONENTS[@]}"
  "${UTIL_COMPONENTS[@]}"
  "${DEV_COMPONENTS[@]}"
  "${APP_COMPONENTS[@]}"
)

get_description() {
  local name=$1
  local index=0
  for comp in "${COMPONENT_NAMES[@]}"; do
    if [[ "$comp" == "$name" ]]; then
      echo "${COMPONENT_DESCRIPTIONS[$index]}"
      return
    fi
    ((index++))
  done
  echo "Unknown component"
}

render_details() {
  local name=$1
  local description=$(get_description "$name")
  printf "   %b%-12s%b %s\n" "${BOLD}${CYAN}" "$name" "${RESET}" "${description}"
}

# Ensure package manager is installed
ensure_pkg_manager() {
  if [[ $OS == "macos" ]]; then
    if ! command_exists brew; then
      print_header "INSTALLING HOMEBREW"
      print_cmd "curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
        print_error "Failed to install Homebrew"
        exit 1
      }
      if [[ $(uname -m) == 'arm64' ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
      fi
      print_success "Homebrew installed successfully"
    else
      print_info "Homebrew is already installed"
    fi
  elif [[ $OS == "ubuntu" ]]; then
    print_info "Updating apt..."
    sudo apt update
  elif [[ $OS == "arch" ]]; then
    print_info "Updating pacman..."
    sudo pacman -Sy --noconfirm
  fi
}

# Install component (per OS)
install_component() {
  local component=$1
  print_header "INSTALLING ${component^^} on $OS_NAME"
  case $component in
    "zsh")
      if ! command_exists zsh; then
        if [[ $OS == "macos" ]]; then
          brew install zsh
        elif [[ $OS == "ubuntu" ]]; then
          sudo apt install -y zsh
        elif [[ $OS == "arch" ]]; then
          sudo pacman -S --noconfirm zsh
        fi
        print_success "zsh installed"
      else
        print_info "zsh is already installed"
      fi
      print_cmd "chsh -s $(which zsh)"
      chsh -s "$(which zsh)" || print_warning "Failed to set zsh as default shell"
      print_cmd "curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
      RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || print_error "Failed to install Oh-My-Zsh"
      print_cmd "git clone https://github.com/chroakPRO/zshdot ~/.zshconfig"
      rm -rf "$HOME/.zshconfig"
      git clone https://github.com/chroakPRO/zshdot "$HOME/.zshconfig" || print_error "Failed to clone zsh configuration"
      print_success "zsh configuration complete"
      ;;
    "ripgrep")
      if ! command_exists rg; then
        if [[ $OS == "macos" ]]; then
          brew install ripgrep
        elif [[ $OS == "ubuntu" ]]; then
          sudo apt install -y ripgrep
        elif [[ $OS == "arch" ]]; then
          sudo pacman -S --noconfirm ripgrep
        fi
        print_success "ripgrep installed"
      else
        print_info "ripgrep is already installed"
      fi
      ;;
    "neovim")
      if ! command_exists nvim; then
        if [[ $OS == "macos" ]]; then
          brew install neovim lua@5.4 luarocks
        elif [[ $OS == "ubuntu" ]]; then
          sudo apt install -y neovim lua5.4 luarocks
        elif [[ $OS == "arch" ]]; then
          sudo pacman -S --noconfirm neovim lua54 luarocks
        fi
        print_success "Neovim, Lua, and LuaRocks installed"
      else
        print_info "Neovim is already installed"
      fi
      print_cmd "git clone https://github.com/chroakPRO/nvimdot $HOME/.config/nvim"
      rm -rf "$HOME/.config/nvim"
      git clone https://github.com/chroakPRO/nvimdot "$HOME/.config/nvim" || print_error "Failed to clone Neovim configuration"
      print_success "Neovim configuration complete"
      ;;
    "dig")
      if ! command_exists dig; then
        if [[ $OS == "macos" ]]; then
          brew install bind
        elif [[ $OS == "ubuntu" ]]; then
          sudo apt install -y dnsutils
        elif [[ $OS == "arch" ]]; then
          sudo pacman -S --noconfirm bind
        fi
        print_success "dig installed"
      else
        print_info "dig is already installed"
      fi
      ;;
    "zoxide")
      if ! command_exists zoxide; then
        if [[ $OS == "macos" ]]; then
          brew install zoxide
        elif [[ $OS == "ubuntu" ]]; then
          sudo apt install -y zoxide
        elif [[ $OS == "arch" ]]; then
          sudo pacman -S --noconfirm zoxide
        fi
        print_success "zoxide installed"
        if [[ -f "$HOME/.zshrc" ]] && ! grep -q "zoxide init" "$HOME/.zshrc"; then
          echo 'eval "$(zoxide init zsh)"' >> "$HOME/.zshrc"
          print_success "zoxide configuration added to .zshrc"
        fi
      else
        print_info "zoxide is already installed"
      fi
      ;;
    "tmux")
      if ! command_exists tmux; then
        if [[ $OS == "macos" ]]; then
          brew install tmux
        elif [[ $OS == "ubuntu" ]]; then
          sudo apt install -y tmux
        elif [[ $OS == "arch" ]]; then
          sudo pacman -S --noconfirm tmux
        fi
        print_success "tmux installed"
      else
        print_info "tmux is already installed"
      fi
      TMUX_CONFIG_DIR="$HOME/.config/tmux"
      rm -rf /tmp/tmuxdot
      git clone https://github.com/chroakPRO/tmuxdot.git /tmp/tmuxdot || print_error "Failed to clone tmux configuration"
      mkdir -p "$TMUX_CONFIG_DIR"
      cp /tmp/tmuxdot/.tmux.conf "$TMUX_CONFIG_DIR/"
      cp /tmp/tmuxdot/README.md "$TMUX_CONFIG_DIR/" 2>/dev/null || true
      print_success "tmux configuration installed to $TMUX_CONFIG_DIR"
      ;;
    "node")
      if ! command_exists node; then
        if [[ $OS == "macos" ]]; then
          brew install node
        elif [[ $OS == "ubuntu" ]]; then
          sudo apt install -y nodejs npm
        elif [[ $OS == "arch" ]]; then
          sudo pacman -S --noconfirm nodejs npm
        fi
        print_success "Node.js and npm installed"
      else
        print_info "Node.js is already installed"
      fi
      print_cmd "npm install -g pnpm"
      npm install -g pnpm || print_error "Failed to install pnpm"
      print_success "pnpm installed"
      ;;
    "miniconda")
      if ! command_exists conda; then
        ARCH=$(uname -m)
        if [[ $OS == "macos" ]]; then
          if [[ "$ARCH" == "arm64" ]]; then
            MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh"
          else
            MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh"
          fi
        elif [[ $OS == "ubuntu" ]]; then
          if [[ "$ARCH" == "x86_64" ]]; then
            MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
          else
            MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh"
          fi
        elif [[ $OS == "arch" ]]; then
          if [[ "$ARCH" == "x86_64" ]]; then
            MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
          else
            MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh"
          fi
        fi
        print_cmd "curl -o ~/miniconda.sh $MINICONDA_URL"
        curl -o "$HOME/miniconda.sh" "$MINICONDA_URL" || print_error "Failed to download Miniconda installer"
        print_cmd "bash $HOME/miniconda.sh -b -p $HOME/miniconda"
        bash "$HOME/miniconda.sh" -b -p "$HOME/miniconda" || { print_error "Failed to install Miniconda"; rm -f "$HOME/miniconda.sh"; }
        rm "$HOME/miniconda.sh"
        "$HOME/miniconda/bin/conda" init bash
        "$HOME/miniconda/bin/conda" init zsh
        "$HOME/miniconda/bin/conda" config --set auto_activate_base true
        print_success "Miniconda installed"
        print_info "Please open a new terminal to start using conda"
      else
        print_info "A conda-based environment is already installed"
      fi
      ;;
    "cursor")
      if ! command_exists cursor; then
        if [[ $OS == "macos" ]]; then
          brew install --cask cursor
          print_success "Cursor IDE installed"
        else
          print_warning "Cursor IDE is only available on macOS (skipping)"
        fi
      else
        print_info "Cursor IDE is already installed"
      fi
      ;;
    "apps")
      if [[ $OS == "macos" ]]; then
        brew install --cask google-chrome 1password magnet hiddenbar
        print_success "All applications installed: Chrome, 1Password, Magnet, Hidden Bar"
      else
        print_warning "GUI apps are only available on macOS (skipping)"
      fi
      ;;
  esac
}

# Main logic
ensure_pkg_manager

if [[ $NON_INTERACTIVE == false ]]; then
  print_header "AVAILABLE COMPONENTS"
  print_header "SHELL"
  printf "%b%2d)%b %bZsh%b           │ Zsh shell with Oh-My-Zsh\n" "${BOLD}${CYAN}" "1" "${RESET}" "${BOLD}" "${RESET}"
  print_header "TEXT EDITING"
  printf "%b%2d)%b %bRipgrep%b       │ Fast text search tool\n" "${BOLD}${CYAN}" "2" "${RESET}" "${BOLD}" "${RESET}"
  printf "%b%2d)%b %bNeovim%b        │ Advanced text editor\n" "${BOLD}${CYAN}" "3" "${RESET}" "${BOLD}" "${RESET}"
  printf "%b%2d)%b %bCursor%b        │ AI-powered code editor\n" "${BOLD}${CYAN}" "4" "${RESET}" "${BOLD}" "${RESET}"
  print_header "UTILITIES"
  printf "%b%2d)%b %bDig%b           │ DNS lookup tools\n" "${BOLD}${CYAN}" "5" "${RESET}" "${BOLD}" "${RESET}"
  printf "%b%2d)%b %bZoxide%b        │ Smarter directory navigation\n" "${BOLD}${CYAN}" "6" "${RESET}" "${BOLD}" "${RESET}"
  printf "%b%2d)%b %bTmux%b          │ Terminal multiplexer\n" "${BOLD}${CYAN}" "7" "${RESET}" "${BOLD}" "${RESET}"
  print_header "DEVELOPMENT"
  printf "%b%2d)%b %bNode.js%b       │ Node.js with npm and pnpm\n" "${BOLD}${CYAN}" "8" "${RESET}" "${BOLD}" "${RESET}"
  printf "%b%2d)%b %bMiniconda%b     │ Python environment manager\n" "${BOLD}${CYAN}" "9" "${RESET}" "${BOLD}" "${RESET}"
  print_header "APPLICATIONS"
  printf "%b%2d)%b %bApps%b          │ Chrome, 1Password, Magnet, Hidden Bar (macOS only)\n" "${BOLD}${CYAN}" "10" "${RESET}" "${BOLD}" "${RESET}"
  print_header "QUICK INSTALL"
  printf "%b%2d)%b %bAll%b           │ Install all components\n" "${BOLD}${CYAN}" "0" "${RESET}" "${BOLD}" "${RESET}"
  printf "\n%b %s %b" "${BOLD}" "Select components to install (space-separated numbers, e.g. '1 3 7'):" "${RESET}"
  read -r choices
  SELECTED_COMPONENTS=()
  if [[ " $choices " == *" 0 "* ]] || [[ "$choices" == "0" ]]; then
    SELECTED_COMPONENTS=("${ALL_COMPONENTS[@]}")
  else
    for choice in $choices; do
      case $choice in
        1) SELECTED_COMPONENTS+=("zsh") ;;
        2) SELECTED_COMPONENTS+=("ripgrep") ;;
        3) SELECTED_COMPONENTS+=("neovim") ;;
        4) SELECTED_COMPONENTS+=("cursor") ;;
        5) SELECTED_COMPONENTS+=("dig") ;;
        6) SELECTED_COMPONENTS+=("zoxide") ;;
        7) SELECTED_COMPONENTS+=("tmux") ;;
        8) SELECTED_COMPONENTS+=("node") ;;
        9) SELECTED_COMPONENTS+=("miniconda") ;;
        10) SELECTED_COMPONENTS+=("apps") ;;
      esac
    done
  fi
  if [[ ${#SELECTED_COMPONENTS[@]} -eq 0 ]]; then
    print_warning "No components selected. Exiting."
    exit 0
  fi
  print_header "INSTALLATION PLAN"
  for component in "${SELECTED_COMPONENTS[@]}"; do
    render_details "$component"
  done
  printf "\n%b %s %b" "${BOLD}" "Proceed with installation? [Y/n]:" "${RESET}"
  read -r confirm
  if [[ "$confirm" =~ ^[Nn] ]]; then
    print_warning "Installation cancelled."
    exit 0
  fi
  total=${#SELECTED_COMPONENTS[@]}
  current=0
  failed=0
  for component in "${SELECTED_COMPONENTS[@]}"; do
    current=$((current + 1))
    if install_component "$component"; then
      printf "\n%b[%d/%d]%b %s installed\n" "${BOLD}${GREEN}" "$current" "$total" "${RESET}" "$component"
    else
      printf "\n%b[%d/%d]%b %s installation failed\n" "${BOLD}${RED}" "$current" "$total" "${RESET}" "$component"
      failed=$((failed + 1))
    fi
  done
else
  if [[ $INSTALL_ALL == true ]]; then
    print_header "NON-INTERACTIVE INSTALLATION"
    print_info "Installing all components..."
    failed=0
    for component in "${ALL_COMPONENTS[@]}"; do
      if ! install_component "$component"; then
        failed=$((failed + 1))
      fi
    done
  else
    print_warning "No components selected for non-interactive mode. Use --install-all to install all components."
    exit 0
  fi
fi

print_header "INSTALLATION COMPLETE"
if [[ ${failed:-0} -gt 0 ]]; then
  print_warning "Some components ($failed) failed to install. Check the log for details."
else
  print_success "Your development environment has been set up on $OS_NAME"
fi
print_info "You may need to restart your terminal for all changes to take effect" 