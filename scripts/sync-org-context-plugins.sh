#!/usr/bin/env bash
# SessionStart hook: mantém o marketplace org-context e os plugins instalados
# em sincronia sem depender de alguém correr comandos manuais após um push.
# Nunca deve bloquear o arranque da sessão (VPN/intranet em baixo é normal).
# Usa python3 em vez de jq (jq não está garantido nesta máquina).
set -u

MARKETPLACE="org-context"
MARKETPLACE_JSON="$HOME/.claude/plugins/marketplaces/$MARKETPLACE/.claude-plugin/marketplace.json"
SETTINGS_JSON="$HOME/.claude/settings.json"

timeout 15 claude plugin marketplace update "$MARKETPLACE" >/dev/null 2>&1

[ -f "$MARKETPLACE_JSON" ] || exit 0
[ -f "$SETTINGS_JSON" ] || exit 0

missing=$(python3 - "$MARKETPLACE_JSON" "$SETTINGS_JSON" "$MARKETPLACE" <<'PYEOF'
import json, sys
marketplace_json, settings_json, marketplace = sys.argv[1], sys.argv[2], sys.argv[3]
try:
    with open(marketplace_json) as f:
        available = {p["name"] for p in json.load(f).get("plugins", [])}
    with open(settings_json) as f:
        enabled_raw = json.load(f).get("enabledPlugins", {}) or {}
    suffix = "@" + marketplace
    enabled = {k[: -len(suffix)] for k in enabled_raw if k.endswith(suffix)}
    for name in sorted(available - enabled):
        print(name)
except Exception:
    pass
PYEOF
)

[ -z "$missing" ] && exit 0

installed_now=()
while IFS= read -r plugin; do
  [ -z "$plugin" ] && continue
  if timeout 20 claude plugin install "${plugin}@${MARKETPLACE}" -s user >/dev/null 2>&1; then
    installed_now+=("$plugin")
  fi
done <<<"$missing"

if [ "${#installed_now[@]}" -gt 0 ]; then
  list=$(IFS=', '; echo "${installed_now[*]}")
  python3 -c "
import json, sys
print(json.dumps({'systemMessage': f\"org-context: instalado(s) plugin(s) novo(s): {sys.argv[1]} (skills disponíveis a partir da próxima sessão)\"}))
" "$list"
fi

exit 0
