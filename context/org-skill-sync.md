# Sincronização de skills do marketplace org-context (cross-tool)

## Estado actual (desde 2026-07-28): automático no Claude Code

O lado Claude Code deste sync **deixou de depender de alguém se lembrar de correr
comandos**. Dois mecanismos, ambos configurados em `~/.claude/settings.json`
(user-scope — aplicam-se a todas as sessões Claude Code, em qualquer projecto,
não só dentro do repo `org-context`):

1. **`extraKnownMarketplaces.org-context.autoUpdate: true`** — mecanismo nativo do
   Claude Code: a cada arranque de sessão, refresca o clone do marketplace e
   actualiza os plugins já instalados.
2. **Hook `SessionStart` → `~/brain/scripts/sync-org-context-plugins.sh`** —
   corre a seguir, faz diff entre os plugins listados no `marketplace.json` e os
   presentes em `enabledPlugins`, e **instala automaticamente** qualquer plugin
   novo (`claude plugin install <plugin>@org-context -s user`). Usa `python3`
   para o diff (não `jq` — não está garantido em todas as máquinas). Timeouts
   curtos (15-20s) e falhas silenciosas: um dia sem VPN/intranet nunca bloqueia
   o arranque da sessão.

**Caveat:** um plugin novo fica instalado na sessão em que o hook corre, mas as
suas skills só ficam disponíveis ao modelo a partir da **sessão seguinte**
(carregamento de plugins acontece no arranque). Ainda resolve o problema de fundo —
nunca mais é preciso lembrar ninguém de correr comandos — só há um atraso de uma
sessão, não dias/semanas como antes.

Isto corrigiu um bug estrutural que já se tinha repetido duas vezes (skill
`commit-push`, 2026-07-08; plugin `openproject`, detectado 2026-07-28 — 8 dias
sem sync até ser apanhado manualmente): o processo antigo só documentava como
**actualizar** um plugin já instalado, nunca como **instalar** um plugin
genuinamente novo — por isso continuava a falhar mesmo depois de "documentado".

## Quando esta página ainda é relevante

- **Troubleshooting** — se o hook falhar (ver secção abaixo) ou quiseres forçar
  uma actualização a meio de sessão sem esperar pelo próximo arranque.
- **Cursor / Codex / qualquer LLM sem plugins nativos** — continuam a depender só
  do fetch HTTP (secção seguinte), que já era automático e não muda com isto.
- **Criar/editar uma skill em `org-context`** — o bump de versão em `plugin.json`
  continua a ser preciso manualmente (ver secção "Regra (após push)").

## Porque o lado Claude Code não era automático (histórico)

Dar push ao repo `org-context` é só uma operação git — não existe nenhum hook/webhook
que avise consumidores do repo de que algo mudou. Há dois mecanismos de consumo, com
comportamento diferente:

| Mecanismo | Como consome | Fica actualizado sozinho? |
|-----------|--------------|----------------------------|
| Fetch via link (`org-context.md`) — **Cursor, Codex, e qualquer LLM sem plugins** | HTTP GET via **`curl` na Shell local** ao raw do ficheiro, **a cada sessão** (nunca WebFetch para intranet) | **Sim** — o próximo curl já traz a versão nova |
| Plugin/marketplace nativo do **Claude Code** (`claude plugin install`) | Clone git local em `~/.claude/plugins/marketplaces/org-context` + cache versionado em `~/.claude/plugins/cache/` | **Desde 2026-07-28: sim**, via `autoUpdate` + hook `SessionStart` acima. Antes disso: não — ficava preso na versão instalada até alguém correr `claude plugin update` manualmente. |

## Cursor: curl fresco, nunca cache nem WebFetch

No **Cursor** (e em qualquer ferramenta que entre pelo brain):

- Consumo = **só** `curl` na Shell local aos URLs listados em `~/brain/org-context.md`.
- **Proibido** WebFetch / fetch cloud para hosts `*.intranet` (não alcança;
  tipicamente 503).
- **Proibido** ler ou executar skills a partir de
  `~/.claude/plugins/cache/org-context/**`, mesmo que o IDE as injecte em
  `available_skills`.
- Depois de um push a `org-context`, **não** é preciso actualizar cache nenhum
  para o Cursor — o próximo `curl` já traz o conteúdo novo.
- Actualizar o cache Claude (`plugin marketplace update` / `plugin update`) é
  irrelevante para o Cursor; só serve sessões Claude Code.

## Regra (após push)

Depois de dar push a uma alteração de skill em `org-context`:

- **Actualizar `~/brain/org-context.md`** se a skill for nova/renomeada/removida
  (lista de URLs raw) — isto é o que o Cursor consome.
- **Antes de tudo (Claude Code), subir a versão em
  `plugins/<plugin>/.claude-plugin/plugin.json`** (patch bump, ex. `1.0.1` →
  `1.0.2`) **e dar commit+push a essa alteração também**.
  `claude plugin update` compara só o número de versão contra o cache instalado —
  se o `SKILL.md` mudou mas a versão ficou igual, o comando responde
  `already at latest version` e **não** actualiza o conteúdo do cache. Sem este
  bump, os passos seguintes são um no-op silencioso — confirmado na prática em
  2026-07-14.
- **Se a sessão actual for Claude Code**, o hook `SessionStart` já trata disto na
  próxima sessão automaticamente — não é preciso correr nada. Se quiseres a
  versão nova **já nesta sessão** (sem esperar pelo próximo arranque), corre
  manualmente:
  ```bash
  claude plugin marketplace update org-context
  claude plugin update <plugin>@org-context    # plugin já instalado, ex.: code-standards@org-context
  claude plugin install <plugin>@org-context   # plugin novo, ainda não instalado
  ```
  e avisa que é preciso **reiniciar a sessão Claude Code** ("Restart to apply
  changes") para as skills ficarem disponíveis. Confirmar `updated from X to Y`
  ou `installed`, nunca `already at latest version` sem mudança.
- **Se for Cursor / Codex / só-fetch:** nada a fazer no cache — o próximo fetch
  via `org-context.md` já traz a versão nova. Confirmar só que o URL está na
  lista do brain.

## Troubleshooting / fallback (hook não correu ou falhou)

Sinais de que o hook falhou: `claude plugin list` não mostra um plugin que já
existe em `~/Projects/org-context`, ou nenhuma `systemMessage` apareceu numa
sessão a seguir a um push com plugin novo. Causas prováveis: VPN/intranet em
baixo no arranque, `python3` em falta, ou o hook desactivado/editado. Correr
manualmente:

```bash
claude plugin marketplace list                 # marketplaces conhecidos + estado
claude plugin list                              # plugins instalados e versão em uso
claude plugin marketplace update org-context    # refresca o clone local a partir do remoto
claude plugin update <plugin>@org-context       # actualiza o cache de um plugin já instalado
claude plugin install <plugin>@org-context      # instala um plugin novo
```

Testar o script do hook directamente (mostra erros que o hook engole em silêncio):
```bash
bash -x ~/brain/scripts/sync-org-context-plugins.sh
```

## Ver também

- `~/brain/scripts/sync-org-context-plugins.sh` — script do hook `SessionStart`.
- `~/.claude/settings.json` → `hooks.SessionStart` +
  `extraKnownMarketplaces.org-context.autoUpdate` — configuração do mecanismo.
- `~/brain/org-context.md` — lista de ficheiros/skills carregados via fetch (canal Cursor).
- `~/brain/MASTER_PROMPT.md` §6–§7 — fetch vs plugins Claude Code.
