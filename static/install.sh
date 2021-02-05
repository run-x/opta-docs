#!/bin/bash
set -u

# Check if script is run non-interactively (e.g. CI)
# If it is run non-interactively we should not prompt for passwords.
if [[ ! -t 0 || -n "${CI-}" ]]; then
  NONINTERACTIVE=1
fi

abort() {
  printf "%s\n" "$1"
  exit 1
}

# Check OS
OS="$(uname)"

# Latest version
VERSION=0.4

# TODO: Handle opta already installed

if [[ "$OS" == "Linux" ]]; then
  echo "Downloading opta zip file"
  curl https://dev-runx-opta-binaries.s3.amazonaws.com/linux/$VERSION/opta.zip -o /tmp/opta.zip

  # Unzip
  unzip -q /tmp/opta.zip -d ~/.opta
  # Enable execution
  chmod u+x ~/.opta/opta

  # TODO: Automatically set up path for github action and other runners
  # TODO: Automatically add to PATH (by adding to profile) for linux users
  echo "Successfully installed! Now you can run opta via invoking ~/.opta/opta"
elif [[ "$OS" == "Darwin" ]]; then
  echo "Downloading opta zip file"
  curl https://dev-runx-opta-binaries.s3.amazonaws.com/linux/$VERSION/opta.zip -o /tmp/opta.zip

  # Unzip
  unzip -q /tmp/opta.zip -d ~/.opta
  # Symlink
  ln -s ~/.opta/opta /usr/local/bin/opta
  # Enable execution
  chmod u+x /usr/local/bin/opta

  echo "Successfully installed! Now you can run opta via invoking opta"
else
  abort "Opta is only supported on macOS and Linux."
fi
