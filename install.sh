#!/usr/bin/env bash

set -euo pipefail

ACTION="${1:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_NAME="continue-unless-blocked"
SOURCE_DIR="${SCRIPT_DIR}/skills/${SKILL_NAME}"
CODEX_ROOT="${CODEX_HOME:-$HOME/.codex}"
TARGET_ROOT="${CODEX_ROOT}/skills"
TARGET_DIR="${TARGET_ROOT}/${SKILL_NAME}"

usage() {
  cat <<'EOF'
Usage: ./install.sh [--update|--uninstall|--help]

Options:
  (no args)     Copy the skill into the Codex skills directory.
  --update      Replace the installed skill with the repo version.
  --uninstall   Remove the installed skill from the Codex skills directory.
  --help        Show this message.
EOF
}

fail() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

require_source() {
  [[ -d "${SOURCE_DIR}" ]] || fail "skill source not found: ${SOURCE_DIR}"
  [[ -f "${SOURCE_DIR}/SKILL.md" ]] || fail "missing source SKILL.md"
  [[ -f "${SOURCE_DIR}/agents/openai.yaml" ]] || fail "missing source agents/openai.yaml"
}

install_or_update() {
  require_source
  mkdir -p "${TARGET_ROOT}"

  local tmp_root
  local tmp_skill_dir
  local backup_dir=""

  tmp_root="$(mktemp -d "${TARGET_ROOT}/.${SKILL_NAME}.tmp.XXXXXX")"
  tmp_skill_dir="${tmp_root}/${SKILL_NAME}"
  mkdir -p "${tmp_skill_dir}"
  cp -R "${SOURCE_DIR}/." "${tmp_skill_dir}/"
  printf '%s\n' "${SCRIPT_DIR}" > "${tmp_skill_dir}/.installed-from"

  if [[ -e "${TARGET_DIR}" && ! -d "${TARGET_DIR}" ]]; then
    rm -rf "${tmp_root}"
    fail "target exists and is not a directory: ${TARGET_DIR}"
  fi

  if [[ -d "${TARGET_DIR}" ]]; then
    backup_dir="$(mktemp -d "${TARGET_ROOT}/.${SKILL_NAME}.backup.XXXXXX")"
    rm -rf "${backup_dir}"
    mv "${TARGET_DIR}" "${backup_dir}"
  fi

  if ! mv "${tmp_skill_dir}" "${TARGET_DIR}"; then
    rm -rf "${tmp_root}"
    if [[ -n "${backup_dir}" && -d "${backup_dir}" ]]; then
      mv "${backup_dir}" "${TARGET_DIR}" || true
    fi
    fail "failed to move skill into place"
  fi

  rm -rf "${tmp_root}"
  if [[ -n "${backup_dir}" && -d "${backup_dir}" ]]; then
    rm -rf "${backup_dir}"
  fi

  printf 'Installed %s to %s\n' "${SKILL_NAME}" "${TARGET_DIR}"
}

uninstall_skill() {
  if [[ ! -e "${TARGET_DIR}" ]]; then
    printf 'No installed skill at %s\n' "${TARGET_DIR}"
    return 0
  fi

  if [[ ! -d "${TARGET_DIR}" ]]; then
    fail "target exists and is not a directory: ${TARGET_DIR}"
  fi

  rm -rf "${TARGET_DIR}"
  printf 'Removed %s from %s\n' "${SKILL_NAME}" "${TARGET_DIR}"
}

case "${ACTION}" in
  "")
    install_or_update
    ;;
  --update)
    install_or_update
    ;;
  --uninstall)
    uninstall_skill
    ;;
  --help)
    usage
    ;;
  *)
    usage
    fail "unknown option: ${ACTION}"
    ;;
esac
