#!/bin/zsh

{ # Ensure the whole script has downloaded


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
  CDU_GITHUB_REPO="${CDU_INSTALL_GITHUB_REPO:-catapult/cdu}"
  local CDU_VERSION
  CDU_VERSION="${CDU_INSTALL_VERSION:-$(cdu_latest_version)}"
  local CDU_SOURCE_URL
  CDU_SOURCE_URL="https://github.com/${CDU_GITHUB_REPO}.git"
  cdu_echo "$CDU_SOURCE_URL"
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


install_cdu_from_git


}