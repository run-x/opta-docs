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

errorevent() {
  curl -X POST https://api2.amplitude.com/2/httpapi \
    -H 'Content-Type: application/json' \
    -H 'Accept: */*' \
    -s \
    -o /dev/null \
    --data-binary @- << EOF
    {
        "api_key": "751db5fc75ff34f08a83381f4d54ead6",
        "events": [
            {
              "device_id": "${MAC_ADDRESS}",
              "user_id": "${GIT_EMAIL}",
              "app_version": "${VERSION}",
              "os_name": "${OS}",
              "event_type": "OPTA_INSTALL_FAILURE"
            }
        ]
    }
EOF
}

trap "errorevent" ERR

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
  hard_prereq=()
  soft_prereq=()
  if ! unzip_loc="$(type -p unzip)" || [[ -z $unzip_loc ]]; then
    hard_prereq+=(unzip)
  fi

  if ! curl_loc="$(type -p curl)" || [[ -z $curl_loc ]]; then
    hard_prereq+=(curl)
  fi

  if ! terraform_loc="$(type -p terraform)" || [[ -z $terraform_loc ]]; then
    soft_prereq+=(terraform)
  fi

  if ! docker_loc="$(type -p docker)" || [[ -z $docker_loc ]]; then
    soft_prereq+=(docker)
  fi

  if [[ ${#hard_prereq[@]} -gt 0 ]]; then
    abort "Please install the following prerequisites: (${hard_prereq[*]})"
  fi

  if [[ ${#soft_prereq[@]} -gt 0 ]]; then
    echo "Opta would require (${soft_prereq[*]}) to run properly. Please install these."
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
  MAC_ADDRESS=`cat /sys/class/net/eth0/address` || true
elif [[ "$OS" == "Darwin" ]]; then
  PACKAGE=https://dev-runx-opta-binaries.s3.amazonaws.com/mac/$VERSION/opta.zip
  MAC_ADDRESS=`ifconfig en1 | awk '/ether/{print $2}'` || true
else
  abort "Opta is only supported on macOS and Linux."
fi

if [[ "$MAC_ADDRESS" == "" ]]; then
  MAC_ADDRESS="unknown"
fi

GIT_EMAIL=`git config user.email` || true
if [[ "$GIT_EMAIL" == "" ]]; then
  GIT_EMAIL="unknown"
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

RUNPATH=~/.opta
# Add symlink if possible, or tell the user to use sudo for symlinking
if ln -fs ~/.opta/opta /usr/local/bin/opta ; then
  echo "Opta symlinked to /usr/local/bin/opta; You can now type 'opta' in the terminal to run it."
else
  echo "Please symlink the opta binary to one of your path directories; for example using 'sudo ln -fs ~/.opta/opta /usr/local/bin/opta'"
  echo "Alternatively, you could add the .opta installation directory to your path like so"
  echo "export PATH=\$PATH:"$RUNPATH
  echo "to your terminal profile."
fi


curl -X POST https://api2.amplitude.com/2/httpapi \
  -H 'Content-Type: application/json' \
  -H 'Accept: */*' \
  -s \
  -o /dev/null \
  --data-binary @- << EOF
  {
      "api_key": "751db5fc75ff34f08a83381f4d54ead6",
      "events": [
          {
            "device_id": "${MAC_ADDRESS}",
            "user_id": "${GIT_EMAIL}",
            "app_version": "${VERSION}",
            "os_name": "${OS}",
            "event_type": "OPTA_INSTALL_SUCCESS"
          }
      ]
  }
EOF
