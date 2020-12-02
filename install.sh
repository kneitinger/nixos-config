#!/usr/bin/env sh

HOSTNAME="$(hostname)"
if [ -n "$1" ]; then
  case "$1" in
    --help | -h)
      echo "$0 [--help] [-h] [HOST]" 
      echo "  --help -h    Show this help message"
      echo "  HOST         The host whose configuraton should be installed."
      echo "               If argument is provided, the output of \`hostname\`"
      echo "               is used as the host."
      exit 0
      ;;
    *)
      HOSTNAME="$1"
      ;;
  esac
fi

echo "  Using hostname $HOSTNAME"

if [ ! -d "hosts/$HOSTNAME" ]; then
  echo "  Error: Missing host folder hosts/$HOSTNAME"
  echo "  Please create the directory and at least one .nix file"
  exit 1
fi

if [ "$(id -u)" -ne 0 ]; then
  echo "  Error: this script must be ran as root. Exiting."
  exit 1
fi


for f in hosts/"$HOSTNAME"/*; do
  echo "  Linking $(pwd)/$f to /etc/nixos/$(basename "$f")"
  ln -sf "$(pwd)/$f" /etc/nixos/"$(basename "$f")"
done

