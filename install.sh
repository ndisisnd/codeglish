#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${HOME}/.claude/skills/codeglish"

REFS=(
  "refs/codeglish-heuristic.md"
  "refs/codeglish-levels.md"
  "refs/codeglish-map.md"
)

INIT_ONLY=(
  "refs/codeglish-exp.json"
  "refs/codeglish-config.json"
)

echo "Installing codeglish → ${INSTALL_DIR}"

mkdir -p "${INSTALL_DIR}/protocol"
mkdir -p "${INSTALL_DIR}/refs"

cp "${SCRIPT_DIR}/SKILL.md" "${INSTALL_DIR}/SKILL.md"

cp "${SCRIPT_DIR}/protocol/"*.md "${INSTALL_DIR}/protocol/"

for ref in "${REFS[@]}"; do
  cp "${SCRIPT_DIR}/${ref}" "${INSTALL_DIR}/${ref}"
done

for ref in "${INIT_ONLY[@]}"; do
  [[ ! -f "${INSTALL_DIR}/${ref}" ]] && cp "${SCRIPT_DIR}/${ref}" "${INSTALL_DIR}/${ref}"
done

echo ""
echo "Done. Run /codeglish in any Claude Code session."
