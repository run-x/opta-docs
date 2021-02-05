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

echo "Welcome to the opta installer."
echo "Going to install opta v$VERSION"

if [[ "$OS" == "Linux" ]]; then
  PACKAGE=https://dev-runx-opta-binaries.s3.amazonaws.com/linux/$VERSION/opta.zip
elif [[ "$OS" == "Darwin" ]]; then
  PACKAGE=https://dev-runx-opta-binaries.s3.amazonaws.com/mac/$VERSION/opta.zip
else
  abort "Opta is only supported on macOS and Linux."
fi

if [[ -d ~/.opta ]]; then
  if [[ -n "${NONINTERACTIVE-}" ]]; then
    echo "Opta already installed. Overwriting..."
    rm -rf ~/.opta
  else
    read -p "Opta already installed. Overwrite? " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      rm -rf ~/.opta
    else
      exit 0
    fi
  fi
fi


echo "Downloading installation package..."
curl -s $PACKAGE -o /tmp/opta.zip
echo "Downloaded"

echo "Installing..."
unzip -q /tmp/opta.zip -d ~/.opta
chmod u+x ~/.opta/opta

if [[ "$OS" == "Darwin" ]];then
  # Add symlink
  ln -fs ~/.opta/opta /usr/local/bin/opta
  RUNPATH=opta
else
  # TODO: Automatically set up path for github action and other runners
  # TODO: Automatically add to PATH (by adding to profile) for linux users
  RUNPATH=~/.opta/opta
fi

echo "Successfully installed! Now you can run it via invoking $RUNPATH"
