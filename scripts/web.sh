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
DEPENDENCIES_UBUNTU="g++ mold clang git pkg-config libx11-dev libasound2-dev libudev-dev libxkbcommon-x11-0 mesa-vulkan-drivers";

# File needed for wasm-bindgen.
WASM_FILE=target/wasm32-unknown-unknown/release/${PROJECT_NAME}.wasm;

# Color and format variables.
BOLD="\e[1m";
RESET_FORMAT="\e[0m";
RED="\e[91m";
GREEN="\e[92m";
CYAN="\e[96m";


# STAGE 1: Update system, Install needed dependencies, Install toolchain and target.

case $ID in # Variable comes from ". /etc/os-release"!
  ubuntu)
      echo -e "${CYAN}This is Ubuntu! Updating system...${RESET_FORMAT}";
      
      # Update system.

      if sudo apt update && sudo apt upgrade 2>&1; then
        echo -e "${GREEN}Successfully updated system!${RESET_FORMAT}";
      else
        echo -e "${BOLD}${RED}There was an error updating the system! Aborting...${RESET_FORMAT}";
        exit 1;
      fi

      # Install dependencies, make sure gcc and mold is installed.

      echo -e "${CYAN}Installing dependencies...${RESET_FORMAT}";

      if sudo apt-get install $DEPENDENCIES_UBUNTU 2>&1; then
        echo -e "${GREEN}Successfully installed dependencies!${RESET_FORMAT}";
      else
        echo -e "${BOLD}${RED}There was an error installing dependencies! Aborting...${RESET_FORMAT}";
        exit 1;
      fi
    ;;

  arch) 
      echo -e "${CYAN}This is Arch! Updating system...${RESET_FORMAT}";

      # Update system.

      if sudo pacman -Syu 2>&1; then
        echo -e "${GREEN}Successfully updated system!${RESET_FORMAT}";
      else
        echo -e "${BOLD}${RED}There was an error updating the system! Aborting...${RESET_FORMAT}";
        exit 1;
      fi

      # Install dependencies, make sure gcc and mold is installed.

      echo -e "${CYAN}Installing dependencies...${RESET_FORMAT}";

      if sudo pacman -S $DEPENDENCIES_ARCH 2>&1; then
        echo -e "${GREEN}Successfully installed dependencies!${RESET_FORMAT}";
      else
        echo -e "${BOLD}${RED}There was an error installing dependencies! Aborting...${RESET_FORMAT}";
        exit 1;
      fi
    ;;

  cachyos)
      echo -e "${CYAN}This is CachyOS! Updating system...${RESET_FORMAT}";

      # Update system.

      if sudo pacman -Syu 2>&1; then
        echo -e "${GREEN}Successfully updated system!${RESET_FORMAT}";
      else
        echo -e "${BOLD}${RED}There was an error updating the system! Aborting...${RESET_FORMAT}";
        exit 1;
      fi

      # Install dependencies, make sure gcc and mold is installed.

      echo -e "${CYAN}Installing dependencies...${RESET_FORMAT}";

      if sudo pacman -S $DEPENDENCIES_ARCH 2>&1; then
        echo -e "${GREEN}Successfully installed dependencies!${RESET_FORMAT}";
      else
        echo -e "${BOLD}${RED}There was an error installing dependencies! Aborting...${RESET_FORMAT}";
        exit 1;
      fi
    ;;

  *)
      echo -e "${BOLD}${RED}This is an unknown distribution! Aborting...${RESET_FORMAT}";
      exit 1;
      ;;
esac


# STAGE 2: Update Rust, Install toolchain, Set toolchain as default, Install target wasm32-unknown-unknown.

echo -e "${CYAN}Updating Rust with rustup...${RESET_FORMAT}";

if rustup update 2>&1; then
  echo -e "${GREEN}Successfully updated Rust using rustup!${RESET_FORMAT}";

  echo -e "${CYAN}Installing Rust toolchain...${RESET_FORMAT}";

  if rustup toolchain install "$RUST_TOOLCHAIN" 2>&1; then
    echo -e "${GREEN}Sucessfully installed ${RUST_TOOLCHAIN}!${RESET_FORMAT}";

    echo -e "${CYAN}Setting $RUST_TOOLCHAIN as default...${RESET_FORMAT}";

    if rustup default "$RUST_TOOLCHAIN" 2>&1; then
      echo -e "${GREEN}Sucessfully set $RUST_TOOLCHAIN as default!${RESET_FORMAT}";

      echo -e "${CYAN}Installing target ${RUST_TARGET}${RESET_FORMAT}";

      if rustup target add $RUST_TARGET >/dev/null 2>&1; then
        echo -e "${GREEN}Sucessfully installed target ${RUST_TARGET}${RESET_FORMAT}";
      else
        echo -e "${RED}${BOLD}There was an error installing target ${RUST_TARGET}! Aborting...${RESET_FORMAT}";
        exit 1;
      fi
    else
      echo -e "${BOLD}${RED}There was an error setting $RUST_TOOLCHAIN as default! Aborting...${RESET_FORMAT}";
      exit 1;
    fi
  else
    echo -e "${BOLD}${RED}There was an error installing ${RUST_TOOLCHAIN}! Aborting...${RESET_FORMAT}";
    exit 1;
  fi
else
  echo -e "${BOLD}${RED}There was an error updating Rust using rustup! Aborting...${RESET_FORMAT}";
  exit 1;
fi


# STAGE 3: Check for wasm-bindgen-cli, if missing install it.

if command -v "$WASM_BINDGEN_BIN" >/dev/null 2>&1; then
    echo -e "${GREEN}Binary $WASM_BINDGEN_BIN is intalled!${RESET_FORMAT}";
else
    echo -e "${BOLD}${RED}Binary $WASM_BINDGEN_BIN could not be found! Installing...${RESET_FORMAT}"
    
    if ! cargo install wasm-bindgen-cli >/dev/null 2>&1; then
      echo -e "${BOLD}${RED}There was an error installing wasm-bindgen-cli! Aborting...${RESET_FORMAT}";
      exit 1;
    fi
fi


# STAGE 4: Compile project with target wasm32-unknown-unknown.

echo -e "${CYAN}Compiling project with target ${RUST_TARGET}${RESET_FORMAT}";

if cargo build --profile wasm-release --target $RUST_TARGET >/dev/null 2>&1; then
  echo -e "${GREEN}Sucessfully compiled project with target ${RUST_TARGET}${RESET_FORMAT}";
else
  echo -e "${RED}${BOLD}There was an error compiling project with target ${RUST_TARGET}! Aborting...${RESET_FORMAT}";
  exit 1;
fi


# STAGE 5: Assemble dist folder.

echo -e "${CYAN}Generating $DIST_FOLDER folder...${RESET_FORMAT}";

if mkdir -p $DIST_FOLDER >/dev/null 2>&1; then # Create dist/.
  if mkdir -p $DIST_ASSETS_FOLDER >/dev/null 2>&1; then # Create dist/assets/.
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
