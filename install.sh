#!/bin/sh

# This script is for installing the latest version of the WarpStream Agent/CLI on your machine.
set -e

# Terminal ANSI escape codes.
reset="\033[0m"
bright_blue="${reset}\033[34;1m"

probe_arch() {
    ARCH=$(uname -m)
    case $ARCH in
        x86_64) ARCH="amd64"  ;;
        aarch64) ARCH="arm64" ;;
        arm64) ARCH="arm64" ;;
        *) printf "Architecture ${ARCH} is not supported by this installation script\n"; exit 1 ;;
    esac
}

probe_os() {
    OS=$(uname -s)
    case $OS in
        Darwin) OS="darwin" ;;
        Linux) OS="linux" ;;
        *) printf "Operating system ${OS} is not supported by this installation script\n"; exit 1 ;;
    esac
}


detect_profile() {
  local DETECTED_PROFILE
  DETECTED_PROFILE=''
  local SHELLTYPE
  SHELLTYPE="$(basename "/$SHELL")"
  if [ "$SHELLTYPE" = "bash" ]; then
    if [ -f "$HOME/.bashrc" ]; then
      DETECTED_PROFILE="$HOME/.bashrc"
    elif [ -f "$HOME/.bash_profile" ]; then
      DETECTED_PROFILE="$HOME/.bash_profile"
    fi
  elif [ "$SHELLTYPE" = "zsh" ]; then
    DETECTED_PROFILE="$HOME/.zshrc"
  elif [ "$SHELLTYPE" = "fish" ]; then
    DETECTED_PROFILE="$HOME/.config/fish/conf.d/warpstream.fish"
  fi
  if [ -z "$DETECTED_PROFILE" ]; then
    if [ -f "$HOME/.profile" ]; then
      DETECTED_PROFILE="$HOME/.profile"
    elif [ -f "$HOME/.bashrc" ]; then
      DETECTED_PROFILE="$HOME/.bashrc"
    elif [ -f "$HOME/.bash_profile" ]; then
      DETECTED_PROFILE="$HOME/.bash_profile"
    elif [ -f "$HOME/.zshrc" ]; then
      DETECTED_PROFILE="$HOME/.zshrc"
    elif [ -d "$HOME/.config/fish" ]; then
      DETECTED_PROFILE="$HOME/.config/fish/conf.d/warpstream.fish"
    fi
  fi
  if [ ! -z "$DETECTED_PROFILE" ]; then
    echo "$DETECTED_PROFILE"
  fi
}

update_profile() {
   PROFILE_FILE=$(detect_profile)
   if ! grep -q "\.warpstream" "$PROFILE_FILE";
   then
      printf "\n${bright_blue}Updating profile ${reset}$PROFILE_FILE\n"
      printf "\n# WarpStream\nexport PATH=\"$INSTALL_DIRECTORY:\$PATH\"\n" >> $PROFILE_FILE
      printf "WarpStream will be available when you open a new terminal.\n"
      printf "If you want to make WarpStream available in this terminal, please run:\n"
      printf "source $PROFILE_FILE\n\n"
    else
      printf "\n${bright_blue}WarpStream detected in your ${reset}$PROFILE_FILE profile already\n\n"
      printf "If you want to ensure WarpStream is available in this terminal, please run:\n\n"
      printf "        source $PROFILE_FILE\n\n"
   fi
}
printf "\nWelcome to the WarpStream installer!\n"

probe_arch
probe_os
URL_PREFIX="https://warpstream-public-us-east-1.s3.amazonaws.com/warpstream_agent_releases"
TARGET="${OS}_$ARCH"
printf "${bright_blue}Downloading ${reset}$TARGET ...\n"
URL="$URL_PREFIX/warpstream_agent_${TARGET}_latest.tar.gz"
DOWNLOAD_FILE=$(mktemp -t warpstream.XXXXXXXXXX)
curl --progress-bar -L "$URL" -o "$DOWNLOAD_FILE"
INSTALL_DIRECTORY="$HOME/.warpstream"
printf "\n${bright_blue}Installing to ${reset}$INSTALL_DIRECTORY\n"
mkdir -p $INSTALL_DIRECTORY
tar -C $INSTALL_DIRECTORY -zxf $DOWNLOAD_FILE
rm -f $DOWNLOAD_FILE
mv $INSTALL_DIRECTORY/warpstream_agent_$TARGET $INSTALL_DIRECTORY/warpstream
update_profile
printf "WarpStream Agent and CLI installed!\n\n"
printf "Try our demo by running: warpstream demo\n\n"
