#!/usr/bin/env bash
set -euo pipefail

brain_root=${BRAIN_ROOT:-"${HOME}/brain"}
skills_root=${OPENCODE_CONFIG_DIR:-"${HOME}/.config/opencode"}/skills
manifest=${brain_root}/org-context.md
cache_dir=${skills_root}/org-context

if [[ ! -r "$manifest" ]]; then
  exit 0
fi

mkdir -p "$cache_dir"

while IFS= read -r url; do
  [[ -z "$url" ]] && continue
  skill_name=${url%/SKILL.md}
  skill_name=${skill_name##*/}
  [[ "$skill_name" =~ ^[a-z0-9][a-z0-9-]*$ ]] || continue

  target_dir=${cache_dir}/${skill_name}
  target_file=${target_dir}/SKILL.md
  temp_file=${target_file}.tmp
  mkdir -p "$target_dir"

  if curl -fsSL --max-time 30 "$url" >"$temp_file"; then
    mv "$temp_file" "$target_file"
  else
    rm -f "$temp_file"
  fi
done < <(rg -o 'https?://[^ )`]+/SKILL\.md' "$manifest" || true)
