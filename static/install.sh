#! /usr/bin/env bash

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

trim_version() {
  version="$1"
  firstChar=${version:0:1}
  if [[ $firstChar = "v" || $firstChar = "V" ]]; then
    version=${version:1}
  fi
  echo $version
}

check_prerequisites() {
  echo "Checking Prerequisites..."
  # declare -a prereq   # Throws "unbound variable" error on Ubuntu 20.04 LTS Focal Fossa on Line #38
  prereq=()
  if ! unzip_loc="$(type -p unzip)" || [[ -z $unzip_loc ]]; then
    prereq+=(unzip)
  fi

  if ! curl_loc="$(type -p curl)" || [[ -z $curl_loc ]]; then
    prereq+=(curl)
  fi

  if [[ ${#prereq[@]} -gt 0 ]]; then
    abort "Please install the following prerequisites: ${prereq[*]}"
  fi
  
}

# Check OS
OS="$(uname)"

echo "Welcome to the opta installer."

check_prerequisites

# Set version
VERSION="${VERSION:-}"

if [[ -z "$VERSION" ]]
then
  # Determine latest version
  echo "Determining latest version"
  VERSION="$(curl -s https://dev-runx-opta-binaries.s3.amazonaws.com/latest)"
else
  VERSION=$(trim_version $VERSION)
fi

echo "Going to install opta v$VERSION"

if [[ "$OS" == "Linux" ]]; then
  PACKAGE=https://dev-runx-opta-binaries.s3.amazonaws.com/linux/$VERSION/opta.zip
elif [[ "$OS" == "Darwin" ]]; then
  PACKAGE=https://dev-runx-opta-binaries.s3.amazonaws.com/mac/$VERSION/opta.zip
else
  abort "Opta is only supported on macOS and Linux."
fi

echo "Downloading installation package..."
curl -s $PACKAGE -o /tmp/opta.zip --fail
if [[ $? != 0 ]]; then
  echo "Version $VERSION not found."
  echo "Please check the available versions at https://github.com/run-x/opta/releases."
  exit 1
fi
echo "Downloaded"

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
      rm -rf /tmp/opta.zip
      exit 0
    fi
  fi
fi


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
  echo "To add opta to your path, please add" 'export PATH=$PATH:'"$RUNPATH" 'to your terminal profile.'
fi

echo "Successfully installed! Now you can run it via invoking $RUNPATH"

