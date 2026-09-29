#!/bin/bash


# Utility functions

msg() { # Usage: msg { FAIL / PASS / INFO } { message }
  local format_bold="\e[1m"
  local format_reset="\e[0m"
  local color_red="\e[91m"
  local color_green="\e[92m"
  local color_cyan="\e[96m"

  case "$1" in
    FAIL) echo -e "${format_bold}${color_red}${2}${format_reset}"; exit 1 ;;
    PASS) echo -e "${color_green}${2}${format_reset}" ;;
    INFO) echo -e "${color_cyan}${2}${format_reset}" ;;
    *) echo -e "${format_bold}${color_red}Wrong use of utility function msg()!${format_reset}"; exit 1 ;;
  esac
}

get_compile_profile() { # Usage: get_compile_profile { release / debug / wasm_release }
    case "$1" in
    release) echo "--release" ;;
    debug) echo "" ;;
    wasm_release) echo "--profile wasm-release" ;;
    *) msg FAIL "Wrong use of utility function get_compile_profile()!" ;;
  esac
}


# Variables

name="comfort-3d"
name_h="Comfort 3D" # Unused

dist_d=${PWD}/dist/
dist_assets_d=${dist_d}/assets/

web_d=${PWD}/web/
assets_d=${PWD}/assets/

r_compile_profile=$( get_compile_profile "$1" )
r_version="$2" || "nightly" # { stable / nightly } Default: nightly
r_toolchain="${r_version}-x86_64-unknown-linux-gnu"
r_target="wasm32-unknown-unknown"

wasm_f=target/wasm32-unknown-unknown/wasm-release/${name}.wasm;
bin_release_f=target/release/${name}
bin_debug_f=target/debug/${name}



# STAGE : Clean up

# Utility functions
unset msg
unset get_compile_profile


# STAGE 1: Update system, Install needed dependencies, Install toolchain and target.

. /etc/os-release # Bring needed variables to scope.

update_ubuntu() { sudo apt update && sudo apt upgrade; }
update_arch() { sudo pacman -Syu; }
update_cachyos() { update_arch "$@"; }
pkg_install_ubuntu() { sudo apt-get install "$@"; }
pkg_install_arch() { sudo pacman -S "$@"; }
pkg_install_cachyos() { pkg_install_arch "$@"; }

typeset -A deps
deps[ubuntu]="g++ mold clang git pkg-config libx11-dev libasound2-dev libudev-dev libxkbcommon-x11-0 mesa-vulkan-drivers"
deps[arch]="libx11 pkgconf alsa-lib libxcursor libxrandr libxi gcc git pipewire-alsa pulseaudio-alsa vulkan-intel vulkan-radeon mold"
deps[cachyos]=${deps[arch]}

case $ID in
    ubuntu|arch|cachyos)
        :
    ;;
    *)
        echo -e "${BOLD}${RED}This is an unknown distribution! Aborting...${RESET_FORMAT}"
        exit 1
    ;;
esac

echo -e "${CYAN}This is $NAME! Updating system...${RESET_FORMAT}"
if update_"$ID" 2>&1; then
    echo -e "${GREEN}Successfully updated system!${RESET_FORMAT}"
else
    echo -e "${BOLD}${RED}There was an error updating the system! Aborting...${RESET_FORMAT}"
    exit 1
fi

echo -e "${CYAN}Installing dependencies...${RESET_FORMAT}"
if pkg_install_"$ID" ${deps[$ID]} 2>&1; then
    echo -e "${GREEN}Successfully installed dependencies!${RESET_FORMAT}"
else
    echo -e "${BOLD}${RED}There was an error installing dependencies! Aborting...${RESET_FORMAT}"
    exit 1
fi


# # STAGE 2: Update Rust, Install toolchain, Set toolchain as default, Install target wasm32-unknown-unknown.

# echo -e "${CYAN}Updating Rust with rustup...${RESET_FORMAT}";

# if rustup update 2>&1; then
#   echo -e "${GREEN}Successfully updated Rust using rustup!${RESET_FORMAT}";

#   echo -e "${CYAN}Installing Rust toolchain...${RESET_FORMAT}";

#   if rustup toolchain install "$RUST_TOOLCHAIN" 2>&1; then
#     echo -e "${GREEN}Sucessfully installed ${RUST_TOOLCHAIN}!${RESET_FORMAT}";

#     echo -e "${CYAN}Setting $RUST_TOOLCHAIN as default...${RESET_FORMAT}";

#     if rustup default "$RUST_TOOLCHAIN" 2>&1; then
#       echo -e "${GREEN}Sucessfully set $RUST_TOOLCHAIN as default!${RESET_FORMAT}";

#       echo -e "${CYAN}Installing target ${RUST_TARGET}${RESET_FORMAT}";

#       if rustup target add $RUST_TARGET >/dev/null 2>&1; then
#         echo -e "${GREEN}Sucessfully installed target ${RUST_TARGET}${RESET_FORMAT}";
#       else
#         echo -e "${RED}${BOLD}There was an error installing target ${RUST_TARGET}! Aborting...${RESET_FORMAT}";
#         exit 1;
#       fi
#     else
#       echo -e "${BOLD}${RED}There was an error setting $RUST_TOOLCHAIN as default! Aborting...${RESET_FORMAT}";
#       exit 1;
#     fi
#   else
#     echo -e "${BOLD}${RED}There was an error installing ${RUST_TOOLCHAIN}! Aborting...${RESET_FORMAT}";
#     exit 1;
#   fi
# else
#   echo -e "${BOLD}${RED}There was an error updating Rust using rustup! Aborting...${RESET_FORMAT}";
#   exit 1;
# fi


# # STAGE 3: Check for wasm-bindgen-cli, if missing install it.

# if command -v "$WASM_BINDGEN_BIN" >/dev/null 2>&1; then
#     echo -e "${GREEN}Binary $WASM_BINDGEN_BIN is intalled!${RESET_FORMAT}";
# else
#     echo -e "${BOLD}${RED}Binary $WASM_BINDGEN_BIN could not be found! Installing...${RESET_FORMAT}"
    
#     if ! cargo install wasm-bindgen-cli >/dev/null 2>&1; then
#       echo -e "${BOLD}${RED}There was an error installing wasm-bindgen-cli! Aborting...${RESET_FORMAT}";
#       exit 1;
#     fi
# fi


# # STAGE 4: Compile project with target wasm32-unknown-unknown.

# echo -e "${CYAN}Compiling project with target ${RUST_TARGET}${RESET_FORMAT}";

# if cargo build --profile wasm-release --target $RUST_TARGET >/dev/null 2>&1; then
#   echo -e "${GREEN}Sucessfully compiled project with target ${RUST_TARGET}${RESET_FORMAT}";
# else
#   echo -e "${RED}${BOLD}There was an error compiling project with target ${RUST_TARGET}! Aborting...${RESET_FORMAT}";
#   exit 1;
# fi


# # STAGE 5: Assemble dist folder.

# echo -e "${CYAN}Generating $DIST_FOLDER folder...${RESET_FORMAT}";

# if mkdir -p $DIST_FOLDER 2>&1; then # Create dist/.
#   if mkdir -p $DIST_ASSETS_FOLDER 2>&1; then # Create dist/assets/.
#     if cp -a $WEB_FOLDER $DIST_FOLDER 2>&1; then # Copy web/ contents to dist/.
#       if cp -a $ASSETS_FOLDER $DIST_ASSETS_FOLDER 2>&1; then # Copy assets/ contents to dist/assets.
#         if wasm-bindgen --out-name $PROJECT_NAME --out-dir $DIST_FOLDER --target web $WASM_FILE 2>&1; then # Use wasm-bindgen to generate files.
#           echo -e "${GREEN}Sucessfully generated ${DIST_FOLDER} folder!${RESET_FORMAT}";
#         else
#           echo -e "${RED}${BOLD}There was an error generating ${DIST_FOLDER}! Aborting...${RESET_FORMAT}";
#           exit 1;
#         fi
#       else
#         echo -e "${RED}${BOLD}There was an error copying files from $ASSETS_FOLDER to ${DIST_ASSETS_FOLDER}! Aborting...${RESET_FORMAT}";
#         exit 1;
#       fi
#     else
#       echo -e "${RED}${BOLD}There was an error copying files from $WEB_FOLDER to ${DIST_FOLDER}! Aborting...${RESET_FORMAT}";
#       exit 1;
#     fi
#   else
#     echo -e "${RED}${BOLD}There was an error creating ${$DIST_ASSETS_FOLDER}! Aborting...${RESET_FORMAT}";
#     exit 1;
#   fi

# else
#   echo -e "${RED}${BOLD}There was an error creating ${DIST_FOLDER}! Aborting...${RESET_FORMAT}";
#   exit 1;
# fi
