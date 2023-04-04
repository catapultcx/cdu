#!/bin/zsh

{ # Ensure the whole script has downloaded

# Inspired by https://github.com/nvm-sh/nvm/blob/master/install.sh

cdu_echo() {
  command printf %s\\n "$*" 2>/dev/null
}

cdu_default_install_dir() {
  [ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.cdu" || printf %s "${XDG_CONFIG_HOME}/cdu"
}

cdu_latest_version() {
  cdu_echo "master"
}

cdu_install_dir() {
  if [ -n "$CDU_DIR" ]; then
    printf %s "${CDU_DIR}"
  else
    cdu_default_install_dir
  fi
}

cdu_source() {
  local CDU_GITHUB_REPO
  CDU_GITHUB_REPO="${CDU_INSTALL_GITHUB_REPO:-catapultcx/cdu}"
  local CDU_VERSION
  CDU_VERSION="${CDU_INSTALL_VERSION:-$(cdu_latest_version)}"
  local CDU_SOURCE_URL
#   CDU_SOURCE_URL="https://github.com/${CDU_GITHUB_REPO}.git"
  CDU_SOURCE_URL="git@github.com:${CDU_GITHUB_REPO}.git"
  cdu_echo "$CDU_SOURCE_URL"
}

try_profile() {
  if [ -z "${1-}" ] || [ ! -f "${1}" ]; then
    return 1
  fi
  cdu_echo "${1}"
}

#
# Detect profile file if not specified as environment variable
# (eg: PROFILE=~/.myprofile)
# The echo'ed path is guaranteed to be an existing file
# Otherwise, an empty string is returned
#
detect_profile() {
  if [ "${PROFILE-}" = '/dev/null' ]; then
    # the user has specifically requested NOT to have cdu touch their profile
    return
  fi

  if [ -n "${PROFILE}" ] && [ -f "${PROFILE}" ]; then
    cdu_echo "${PROFILE}"
    return
  fi

  local DETECTED_PROFILE
  DETECTED_PROFILE=''

  if [ "${SHELL#*bash}" != "$SHELL" ]; then
    if [ -f "$HOME/.bashrc" ]; then
      DETECTED_PROFILE="$HOME/.bashrc"
    elif [ -f "$HOME/.bash_profile" ]; then
      DETECTED_PROFILE="$HOME/.bash_profile"
    fi
  elif [ "${SHELL#*zsh}" != "$SHELL" ]; then
    if [ -f "$HOME/.zshrc" ]; then
      DETECTED_PROFILE="$HOME/.zshrc"
    elif [ -f "$HOME/.zprofile" ]; then
      DETECTED_PROFILE="$HOME/.zprofile"
    fi
  fi

  if [ -z "$DETECTED_PROFILE" ]; then
    for EACH_PROFILE in ".profile" ".bashrc" ".bash_profile" ".zprofile" ".zshrc"
    do
      if DETECTED_PROFILE="$(try_profile "${HOME}/${EACH_PROFILE}")"; then
        break
      fi
    done
  fi

  if [ -n "$DETECTED_PROFILE" ]; then
    cdu_echo "$DETECTED_PROFILE"
  fi
}


uninstall_cdu() {
  local INSTALL_DIR
  INSTALL_DIR="$(cdu_install_dir)"
  cdu_echo "$INSTALL_DIR"
  rm -rf $INSTALL_DIR
}

install_cdu_from_git() {
  local INSTALL_DIR
  INSTALL_DIR="$(cdu_install_dir)"
  CDU_VERSION="${CDU_INSTALL_VERSION:-$(cdu_latest_version)}"

  local fetch_error
  if [ -d "$INSTALL_DIR/.git" ]; then
    # Updating repo
    cdu_echo "=> cdu is already installed in $INSTALL_DIR, trying to update using git"
    command printf '\r=> '
    fetch_error="Failed to update cdu with $NVM_VERSION, run 'git fetch' in $INSTALL_DIR yourself."
  else
    fetch_error="Failed to fetch origin with $NVM_VERSION. Please report this!"
    cdu_echo "=> Downloading cdu from git to '$INSTALL_DIR'"
    command printf '\r=> '
    mkdir -p "${INSTALL_DIR}"
    if [ "$(ls -A "${INSTALL_DIR}")" ]; then
      # Initializing repo
      command git init "${INSTALL_DIR}" || {
        cdu_echo >&2 'Failed to initialize cdu repo. Please report this!'
        exit 2
      }
      command git --git-dir="${INSTALL_DIR}/.git" remote add origin "$(cdu_source)" 2> /dev/null \
        || command git --git-dir="${INSTALL_DIR}/.git" remote set-url origin "$(cdu_source)" || {
        cdu_echo >&2 'Failed to add remote "origin" (or set the URL). Please report this!'
        exit 2
      }
    else
      # Cloning repo
      command git clone "$(cdu_source)" --depth=1 "${INSTALL_DIR}" || {
        cdu_echo >&2 'Failed to clone cdu repo. Please report this!'
        exit 2
      }
    fi
  fi

}

cdu_do_install() {
  install_cdu_from_git
  cdu_echo 
  cdu_echo "Now add the install dir to your path in $(detect_profile)"
  cdu_reset
}

cdu_reset() {
  unset -f cdu_install_dir cdu_latest_version  \
    cdu_source install_cdu_from_git  \
    cdu_do_install cdu_reset 
}

cdu_do_install

}