#!/bin/sh
## Startup script for testing wireguard in docker.

set -eu
version="1.0"

###############################################################################
# Environment
###############################################################################

IMG_NAME="wg-test"
IMG_VER="latest"
SERVICE_NAME="wg-test"

VERBOSE=0
REBUILD=0

###############################################################################
# Options
###############################################################################

usage() {
  echo -n "$0 [-hvre] PATH

Spawn a dockerized container of Wireguard, and mount the
provided path to /etc/wireguard.

Options:
  -r            Rebuild the docker image.
  -e            Output more information during image build.
  -h            Display this help and exit.
  -v            Output version information and exit.
"
}

while getopts ervh OPT; do
  case $OPT in
    e) VERBOSE=1 ;;
    r) REBUILD=1 ;;
    v) echo "$(basename $0) ${version}"; exit 1;;
    h) usage >&2; exit 1;;
    \?) echo "Invalid option: $OPT"; exit 1;;
  esac
done

shift `expr $OPTIND - 1`

if [ $# -eq 0 ]; then
    usage >&2; exit 1
fi

###############################################################################
# Methods
###############################################################################

spin() {
  i=0; sp='/-\|'
  printf ' '
  sleep 0.5
  while [ "$i" -lt 120 ]; do
    printf '\b%.1s' "$sp"
    i=$((i+1)); sp=${sp#?}${sp%???}
    sleep 0.5
  done
}

stop_container() {
  if docker container ls | grep $SERVICE_NAME > /dev/null 2>&1; then
    echo "Stopping current container..."
    docker container stop $SERVICE_NAME > /dev/null 2>&1
  fi
}

###############################################################################
# Main Script
###############################################################################

if [ -n $1 ]; then
  SERVICE_NAME="${SERVICE_NAME}-$1"
fi

if [ $REBUILD -eq 1 ]; then
  if docker image ls | grep $IMG_NAME > /dev/null 2>&1; then
    echo "Removing existing '$IMG_NAME' image..."
    docker image rm $IMG_NAME > /dev/null 2>&1
  fi
fi

if ! docker image ls | grep $IMG_NAME > /dev/null 2>&1; then
  printf "Building new '$IMG_NAME' image from dockerfile... "
  if [ $VERBOSE -eq 1 ]; then
    printf "\n"
    docker build --tag $IMG_NAME .
  else
    spin & spinpid=$!
    docker build --tag $IMG_NAME . > /dev/null 2>&1
    kill "$spinpid"
    printf "\n"
  fi
fi

stop_container
echo "Starting '$SERVICE_NAME' container... "

docker run -it --rm \
  --name $SERVICE_NAME \
  --mount type=bind,source=$(pwd)/$1,target=/etc/wireguard \
  --mount type=bind,source=/lib/modules,target=/lib/modules \
  --mount type=bind,source=/usr/src,target=/usr/src,readonly \
  --sysctl="net.ipv4.conf.all.src_valid_mark=1" \
  --cap-add=NET_ADMIN \
  --privileged \
  -p 51820:51820 \
$IMG_NAME:$IMG_VER