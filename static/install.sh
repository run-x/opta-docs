#! /usr/bin/env bash

set -u

# Check if script is run non-interactively (e.g. CI)
# If it is run non-interactively we should not prompt for passwords.
if [[ ! -t 0 || -n "${CI-}" ]]; then
  NONINTERACTIVE=1
fi

LEGACY_DOWNLOAD=1

abort() {
  printf "%s\n" "$1"
  exit 1
}

sendamplitudeevent() {
  (curl -X POST https://api2.amplitude.com/2/httpapi \
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
                "event_type": "$1"
              }
          ]
      }
EOF
    ) || true
}

errorevent() {
  sendamplitudeevent "OPTA_INSTALL_FAILURE"
}

trap "errorevent" ERR

# Compares two version numbers.
# Returns 0 if the versions are equal, 1 if the first version is higher, and 2 if the second version is higher.
compare_version () {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            echo 1
            return
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            echo 2
            return
        fi
    done
    echo 0
    return
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

if [[ $(compare_version "$VERSION" "0.26.0") == 1 ]]; then
  LEGACY_DOWNLOAD=0
fi

echo "Going to install opta v$VERSION"

if [[ "$OS" == "Linux" ]]; then
  SPECIFIC_OS_ID=`grep "ID=" /etc/os-release | awk -F"=" '{print $2;exit}' | tr -d '"'`
  if [[ "$SPECIFIC_OS_ID" == "amzn" ]] || [[ "$SPECIFIC_OS_ID" == "centos" ]]; then
    if [[ "$LEGACY_DOWNLOAD" == "1" ]]; then
      PACKAGE=https://dev-runx-opta-binaries.s3.amazonaws.com/centos/$VERSION/opta.zip
    else
      PACKAGE=https://github.com/run-x/opta/releases/download/v$VERSION/opta_centos.zip
    fi
  else
    if [[ "$LEGACY_DOWNLOAD" == "1" ]]; then
      PACKAGE=https://dev-runx-opta-binaries.s3.amazonaws.com/linux/$VERSION/opta.zip
    else
      PACKAGE=https://github.com/run-x/opta/releases/download/v$VERSION/opta_linux.zip
    fi
  fi
  MAC_ADDRESS=`cat /sys/class/net/eth0/address 2> /dev/null` || true
elif [[ "$OS" == "Darwin" ]]; then
  if [[ "$LEGACY_DOWNLOAD" == "1" ]]; then
    PACKAGE=https://dev-runx-opta-binaries.s3.amazonaws.com/mac/$VERSION/opta.zip
  else
    PACKAGE=https://github.com/run-x/opta/releases/download/v$VERSION/opta_mac.zip
  fi
  MAC_ADDRESS=`ifconfig en1 2> /dev/null | awk '/ether/{print $2}'` || true
else
  abort "Opta is only supported on macOS and Linux."
fi

if [[ "$MAC_ADDRESS" == "" ]]; then
  MAC_ADDRESS="unknown"
fi

GIT_EMAIL=`git config user.email 2> /dev/null ` || true
if [[ "$GIT_EMAIL" == "" ]]; then
  GIT_EMAIL="unknown"
fi

echo "Downloading installation package..."
curl -s -L $PACKAGE -o /tmp/opta.zip --fail
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
rm -rf /tmp/opta.zip
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

sendamplitudeevent "OPTA_INSTALL_SUCCESS"
