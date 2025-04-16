#!/bin/bash

# Terminal colors
CYAN=$'\e[36m'
GREEN=$'\e[32m'
YELLOW=$'\e[33m'
BLUE=$'\e[34m'
GRAY=$'\e[90m'
BOLD=$'\e[1m'
RESET=$'\e[0m'

# Function to print with style
print() {
  local color=$1
  local text=$2
  printf "%b%s%b\n" "${color}" "${text}" "${RESET}"
}

# Function to print a command
print_cmd() {
  printf "%b$ %s%b\n" "${GRAY}" "$1" "${RESET}"
}

# Function to print a header
print_header() {
  printf "\n%b%s%b\n" "${BOLD}${BLUE}" "$1" "${RESET}"
  printf "%b%s%b\n" "${BLUE}" "$(printf '─%.0s' $(seq 1 ${#1}))" "${RESET}"
}

# Function to print a success message
print_success() {
  printf "%b✓ %s%b\n" "${GREEN}" "$1" "${RESET}"
}

# Function to print an info message
print_info() {
  printf "%b• %s%b\n" "${CYAN}" "$1" "${RESET}"
}

# Function to print a warning
print_warning() {
  printf "%b! %s%b\n" "${YELLOW}" "$1" "${RESET}"
}

# Function to print an error
print_error() {
  printf "%b✗ %s%b\n" "${RED}" "$1" "${RESET}" >&2
}

# Function to show the welcome message
show_welcome() {
  clear
  printf "\n%b" "${BOLD}${CYAN}"
  cat << "EOF"
┌────────────────────────────────────────────────┐
│                                                │
│               macOS Quick Setup                │
│          [developer environment tool]          │
│                                                │
└────────────────────────────────────────────────┘
EOF
  printf "%b\n\n" "${RESET}"
  print_info "Setup your macOS developer environment with a single command"
  printf "\n"
}

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
      print_error "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Display help if requested
if [[ $SHOW_HELP == true ]]; then
  print_header "USAGE"
  print "${BOLD}" "  ./install.sh [OPTIONS]"
  print_header "OPTIONS"
  print_info "  --non-interactive    Run without prompts (skips all installations)"
  print_info "  --install-all        Install all components without prompting"
  print_info "  --help               Show this help message"
  exit 0
fi

# Show welcome screen if in interactive mode
if [[ $NON_INTERACTIVE == false ]]; then
  show_welcome
fi

# Component definitions 
declare -A components
components["zsh"]="Zsh shell with Oh-My-Zsh"
components["ripgrep"]="Fast text search tool"
components["neovim"]="Advanced text editor"
components["cursor"]="AI-powered code editor" 
components["dig"]="DNS lookup tools"
components["zoxide"]="Smarter directory navigation"
components["tmux"]="Terminal multiplexer"
components["node"]="Node.js and npm"
components["miniconda"]="Python environment manager"
components["apps"]="Chrome, 1Password, Magnet, Hidden Bar"
components["all"]="Install all components"

# Create component categories for a better organization 
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

# Function to render component details
render_details() {
  local name=$1
  local description=${components[$name]}
  printf "   %b%-12s%b %s\n" "${BOLD}${CYAN}" "$name" "${RESET}" "${description}"
}

# Check if Homebrew is installed
ensure_homebrew() {
  if ! command_exists brew; then
    print_header "INSTALLING HOMEBREW"
    print_cmd "curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for ARM Macs if needed
    if [[ $(uname -m) == 'arm64' ]]; then
      echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    print_success "Homebrew installed successfully"
  else
    print_info "Homebrew is already installed"
  fi
}

# Install components
install_component() {
  local component=$1
  
  print_header "INSTALLING ${component^^}"
  
  case $component in
    "zsh")
      if ! command_exists zsh; then
        print_cmd "brew install zsh"
        brew install zsh
        print_success "zsh installed"
      else
        print_info "zsh is already installed"
      fi

      # Set zsh as default shell
      print_cmd "chsh -s $(which zsh)"
      chsh -s "$(which zsh)"

      # Install oh-my-zsh
      print_cmd "curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
      RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

      # Download zsh config
      print_cmd "git clone https://github.com/chroakPRO/zshdot ~/.zshconfig"
      rm -rf "$HOME/.zshconfig"
      git clone https://github.com/chroakPRO/zshdot "$HOME/.zshconfig"
      print_success "zsh configuration complete"
      ;;
      
    "ripgrep")
      if ! command_exists rg; then
        print_cmd "brew install ripgrep"
        brew update && brew install ripgrep
        print_success "ripgrep installed"
      else
        print_info "ripgrep is already installed"
      fi
      ;;
      
    "neovim")
      # Install Lua 5.4 and LuaRocks
      if ! command_exists lua; then
        print_cmd "brew install lua@5.4 luarocks"
        brew update
        brew install lua@5.4
        brew install luarocks
        print_success "Lua 5.4 and LuaRocks installed"
      else
        print_info "Lua is already installed"
      fi

      if ! command_exists nvim; then
        print_cmd "brew install neovim"
        brew update
        brew install neovim
        print_success "Neovim installed"
      else
        print_info "Neovim is already installed"
      fi

      # Download Neovim config
      print_cmd "git clone https://github.com/chroakPRO/nvimdot $HOME/.config/nvim"
      rm -rf "$HOME/.config/nvim"
      git clone https://github.com/chroakPRO/nvimdot "$HOME/.config/nvim"
      print_success "Neovim configuration complete"
      ;;
      
    "dig")
      if ! command_exists dig; then
        print_cmd "brew install bind"
        brew update
        brew install bind
        print_success "dig installed"
      else
        print_info "dig is already installed"
      fi
      ;;
      
    "zoxide")
      if ! command_exists zoxide; then
        print_cmd "brew install zoxide"
        brew update
        brew install zoxide
        print_success "zoxide installed"
        
        # Add zoxide to shell configuration
        if [[ -f "$HOME/.zshrc" ]]; then
          if ! grep -q "zoxide init" "$HOME/.zshrc"; then
            echo 'eval "$(zoxide init zsh)"' >> "$HOME/.zshrc"
            print_success "zoxide configuration added to .zshrc"
          fi
        fi
      else
        print_info "zoxide is already installed"
      fi
      ;;
      
    "tmux")
      if ! command_exists tmux; then
        print_cmd "brew install tmux"
        brew update
        brew install tmux
        print_success "tmux installed"
      else
        print_info "tmux is already installed"
      fi

      # Install oh-my-tmux
      print_cmd "git clone https://github.com/chroakPRO/tmuxdot.git $HOME/.tmux"
      git clone https://github.com/chroakPRO/tmuxdot.git "$HOME/.tmux"
      cp "$HOME/.tmux/.tmux.conf" "$HOME/.tmux.conf"
      print_success "tmux configuration complete"
      ;;
      
    "node")
      if ! command_exists node; then
        print_cmd "brew install node"
        brew update
        brew install node
        print_success "Node.js and npm installed"
      else
        print_info "Node.js is already installed"
      fi

      # Install pnpm
      print_cmd "npm install -g pnpm"
      npm install -g pnpm
      print_success "pnpm installed"
      ;;
      
    "miniconda")
      if ! command_exists conda; then
        print_cmd "curl -o ~/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh"
        curl -o "$HOME/miniconda.sh" https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh
        
        print_cmd "bash ~/miniconda.sh -b -p ~/miniconda"
        bash "$HOME/miniconda.sh" -b -p "$HOME/miniconda"
        rm "$HOME/miniconda.sh"

        print_cmd "~/miniconda/bin/conda init bash zsh"
        "$HOME/miniconda/bin/conda" init bash
        "$HOME/miniconda/bin/conda" init zsh

        print_cmd "~/miniconda/bin/conda config --set auto_activate_base true"
        "$HOME/miniconda/bin/conda" config --set auto_activate_base true

        print_success "Miniconda installed"
        print_info "Please open a new terminal to start using conda"
      else
        print_info "A conda-based environment is already installed"
      fi
      ;;
      
    "cursor")
      if ! command_exists cursor; then
        print_cmd "brew install --cask cursor"
        brew update
        brew install --cask cursor
        print_success "Cursor IDE installed"
      else
        print_info "Cursor IDE is already installed"
      fi
      ;;
      
    "apps")
      print_cmd "brew install --cask google-chrome 1password magnet hiddenbar"
      print_info "Installing Chrome..."
      brew install --cask google-chrome
      print_success "Chrome installed"
      
      print_info "Installing 1Password..."
      brew install --cask 1password
      print_success "1Password installed"
      
      print_info "Installing Magnet..."
      brew install --cask magnet
      print_success "Magnet installed"
      
      print_info "Installing Hidden Bar..."
      brew install --cask hiddenbar
      print_success "Hidden Bar installed"
      ;;
  esac
}

# Ensure Homebrew is installed
ensure_homebrew

# Interactive installation
if [[ $NON_INTERACTIVE == false ]]; then
  print_header "AVAILABLE COMPONENTS"
  
  # Display all components with their descriptions and numbers
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
  printf "%b%2d)%b %bApps%b          │ Chrome, 1Password, Magnet, Hidden Bar\n" "${BOLD}${CYAN}" "10" "${RESET}" "${BOLD}" "${RESET}"
  
  print_header "QUICK INSTALL"
  printf "%b%2d)%b %bAll%b           │ Install all components\n" "${BOLD}${CYAN}" "0" "${RESET}" "${BOLD}" "${RESET}"
  
  printf "\n%b %s %b" "${BOLD}" "Select components to install (space-separated numbers, e.g. '1 3 7'):" "${RESET}"
  read -r choices
  
  # Process the selected components
  SELECTED_COMPONENTS=()
  
  # Check if all components are selected
  if [[ "$choices" == *"0"* ]]; then
    SELECTED_COMPONENTS=("${ALL_COMPONENTS[@]}")
  else
    # Map chosen numbers to component names
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
  
  # If no components selected, exit
  if [[ ${#SELECTED_COMPONENTS[@]} -eq 0 ]]; then
    print_warning "No components selected. Exiting."
    exit 0
  fi
  
  # Show which components will be installed
  print_header "INSTALLATION PLAN"
  for component in "${SELECTED_COMPONENTS[@]}"; do
    render_details "$component"
  done
  
  # Confirmation prompt
  printf "\n%b %s %b" "${BOLD}" "Proceed with installation? [Y/n]:" "${RESET}"
  read -r confirm
  if [[ "$confirm" =~ ^[Nn] ]]; then
    print_warning "Installation cancelled."
    exit 0
  fi
  
  # Install selected components with simple progress feedback
  total=${#SELECTED_COMPONENTS[@]}
  current=0
  
  for component in "${SELECTED_COMPONENTS[@]}"; do
    current=$((current + 1))
    install_component "$component"
    printf "\n%b[%d/%d]%b %s installed\n" "${BOLD}${GREEN}" "$current" "$total" "${RESET}" "$component"
  done
  
else
  # Non-interactive installation
  if [[ $INSTALL_ALL == true ]]; then
    print_header "NON-INTERACTIVE INSTALLATION"
    print_info "Installing all components..."
    
    for component in "${ALL_COMPONENTS[@]}"; do
      install_component "$component"
    done
  fi
fi

# Summary
print_header "INSTALLATION COMPLETE"
print_success "Your macOS development environment has been set up"
print_info "You may need to restart your terminal for all changes to take effect"
