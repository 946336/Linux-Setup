#!/usr/bin/env bash
# Set up a fresh Ubuntu VM
# Does not attempt to set any keyboard shortcuts

set -e

PREFIX="$HOME"

FEATURE_NGX=
FEATURE_YCM=
FEATURE_DEV=
FEATURE_CXX=
FEATURE_PY=

_help() {
    echo -e "Setup script intended for fresh Ubuntu images"
    echo -e "Features recognized:"
    echo -e "\tycm"
    echo -e "\tdev"
    echo -e "\tc++"
    echo -e "\tpython"
    echo -e "\tnginx"
}

install_prerequisites() {
    sudo apt-get install -y git vim vim-gtk3
}

unrecognized() { #argument
    echo "Unrecognized argument: $1"
}

lowercase() { # string_to_convert
    echo "${1:-''}" | tr '[A-Z]' '[a-z]'
}

setup_vim_maybe_ycm() {
    pushd "$HOME"

    mkdir -p "$PREFIX"
    pushd "$PREFIX"

    if [[ ! -d Dotfiles ]]; then
        git clone "https://github.com/946336/Dotfiles.git" Dotfiles
    fi
    pushd Dotfiles

    local install_target=vim-no-ycm
    if [[ -n "$FEATURE_YCM" ]]; then
        install_target=vim
    fi

    ./install-dotfiles.bash "$install_target"

    popd
    popd
    popd
}

maybe_install_dev () {
    if [[ -z "$FEATURE_DEV" ]]; then
        return
    fi

    sudo apt-get install -y build-essential
}

maybe_install_cxx() {
    sudo apt-get install -y g++ gcc make cmake valgrind gdb
}

maybe_install_python() {
    if [[ -z "$FEATURE_PY" ]]; then
        return
    fi
    sudo apt-get install -y python3 pip3
}

maybe_install_nginx() {
    if [[ -z "$FEATURE_NGX" ]]; then
        return
    fi

    # Install certbot
    # (from # https://certbot.eff.org/lets-encrypt/ubuntubionic-nginx)
    sudo apt-get update
    sudo apt-get install software-properties-common
    sudo add-apt-repository universe
    sudo add-apt-repository ppa:certbot/certbot
    sudo apt-get update
    sudo apt-get install -y certbot python-certbot-nginx

    sudo apt-get install -y nginx
}

while [[ $# -gt 0 ]];
do
    __lower="$(lowercase "$1")"
    case "$__lower" in
        webserver|nginx)
            FEATURE_NGX=true
            shift
            ;;
        python|py)
            FEATURE_PY=true
            shift
            ;;
        prefix)
            PREFIX="$1"
            shift
            ;;
        cxx|g++|c++|cpp)
            FEATURE_CXX=true
            shift
            ;;
        dev)
            FEATURE_DEV=true
            shift
            ;;
        ycm)
            FEATURE_YCM=true
            shift
            ;;
        -h|--help)
            _help
            exit 0
            ;;
        *)
            unrecognized "$1"
            exit 1
            ;;
    esac
done
unset __lower

install_prerequisites

setup_vim_maybe_ycm
maybe_install_cxx
maybe_install_dev
maybe_install_nginx
maybe_install_python

