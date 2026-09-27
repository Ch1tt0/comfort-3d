#!/bin/bash


# Variables.

. /etc/os-release # Bring needed variables to scope.

PROJECT_NAME="comfort-3d"; # Name.
HUMAN_PROJECT_NAME="Comfort 3D"; # Human readable name.

WASM_BINDGEN_BIN="wasm-bindgen"; # Name of wasm-bindgen-cli executable.

DIST_FOLDER=dist/; # Distribution folder.
DIST_ASSETS_FOLDER=dist/assets/; # Distrubution assets folder.
WEB_FOLDER=web/.; # Web folder.
ASSETS_FOLDER=assets/.; # Assets folder.

RUST_TOOLCHAIN="nightly-x86_64-unknown-linux-gnu"; # Nightly Rust toolchain.
RUST_TARGET="wasm32-unknown-unknown"; # Rust wasm target.

# Dependencies for Arch and Arch derived distros.
DEPENDENCIES_ARCH="libx11 pkgconf alsa-lib libxcursor libxrandr libxi gcc git pipewire-alsa pulseaudio-alsa vulkan-intel vulkan-radeon mold";

# Dependencies for Ubuntu.
DEPENDENCIES_UBUNTU="g++ mold clang git pkg-config libx11-dev libasound2-dev libudev-dev libxkbcommon-x11-0 vulkan-radeon vulkan-intel mesa-vulkan-drivers";

# File needed for wasm-bindgen.
WASM_FILE=target/wasm32-unknown-unknown/release/${PROJECT_NAME}.wasm;

# Color and format variables.
BOLD="\e[1m";
RESET_FORMAT="\e[0m";
RED="\e[91m";
GREEN="\e[92m";
CYAN="\e[96m";

echo -e "${CYAN}Generating $DIST_FOLDER folder...${RESET_FORMAT}";

if mkdir $DIST_FOLDER >/dev/null 2>&1; then # Create dist/.
  if mkdir $DIST_ASSETS_FOLDER >/dev/null 2>&1; then # Create dist/assets/.
    if cp -a $WEB_FOLDER $DIST_FOLDER >/dev/null 2>&1; then # Copy web/ contents to dist/.
      if cp -a $ASSETS_FOLDER $DIST_ASSETS_FOLDER >/dev/null 2>&1; then # Copy assets/ contents to dist/assets.
        if wasm-bindgen --out-name $PROJECT_NAME --out-dir $DIST_FOLDER --target web $WASM_FILE 2>&1; then # Use wasm-bindgen to generate files.
          echo -e "${GREEN}Sucessfully generated ${DIST_FOLDER} folder!${RESET_FORMAT}";
        else
          echo -e "${RED}${BOLD}There was an error generating ${DIST_FOLDER}! Aborting...${RESET_FORMAT}";
          exit 1;
        fi
      else
        echo -e "${RED}${BOLD}There was an error copying files from $ASSETS_FOLDER to ${DIST_ASSETS_FOLDER}! Aborting...${RESET_FORMAT}";
        exit 1;
      fi
    else
      echo -e "${RED}${BOLD}There was an error copying files from $WEB_FOLDER to ${DIST_FOLDER}! Aborting...${RESET_FORMAT}";
      exit 1;
    fi
  else
    echo -e "${RED}${BOLD}There was an error creating ${$DIST_ASSETS_FOLDER}! Aborting...${RESET_FORMAT}";
    exit 1;
  fi

else
  echo -e "${RED}${BOLD}There was an error creating ${DIST_FOLDER}! Aborting...${RESET_FORMAT}";
  exit 1;
fi