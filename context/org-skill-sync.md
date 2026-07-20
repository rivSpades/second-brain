# Sincronização de skills do marketplace org-context (cross-tool)

## Quando se aplica

Sempre que crias, editas ou removes um `SKILL.md` (ou `plugin.json`/`marketplace.json`)
dentro do workspace `~/Projects/org-context` — fonte do marketplace de plugins
partilhado da organização — e vais fazer commit + push dessa alteração (normalmente via
`/commit-push`).

## Porque não é automático

Dar push ao repo `org-context` é só uma operação git — não existe nenhum hook/webhook
que avise consumidores do repo de que algo mudou. Há dois mecanismos de consumo, com
comportamento diferente:

| Mecanismo | Como consome | Fica actualizado sozinho? |
|-----------|--------------|----------------------------|
| Fetch via link (`org-context.md`) — **Cursor, Codex, e qualquer LLM sem plugins** | HTTP GET directo ao raw do ficheiro, **a cada sessão** | **Sim** — o próximo fetch já traz a versão nova |
| Plugin/marketplace nativo do **Claude Code** (`claude plugin install`) | Clone git local em `~/.claude/plugins/marketplaces/org-context` + cache versionado em `~/.claude/plugins/cache/` | **Não** — fica preso na versão instalada até `claude plugin update` |

## Cursor: fetch fresco, nunca cache

No **Cursor** (e em qualquer ferramenta que entre pelo brain):

- Consumo = **só** fetch HTTP listado em `~/brain/org-context.md`.
- **Proibido** ler ou executar skills a partir de
  `~/.claude/plugins/cache/org-context/**`, mesmo que o IDE as injecte em
  `available_skills`.
- Depois de um push a `org-context`, **não** é preciso actualizar cache nenhum
  para o Cursor — a próxima sessão (ou o próximo fetch) já traz o conteúdo novo.
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
- **Se a sessão actual for Claude Code** e o plugin estiver instalado via
  marketplace (confirmar com `claude plugin list`): correr imediatamente
  ```bash
  claude plugin marketplace update org-context
  claude plugin update <plugin>@org-context   # ex.: code-standards@org-context
  ```
  e avisar que é preciso **reiniciar a sessão Claude Code** ("Restart to apply
  changes"). Confirmar `updated from X to Y`, nunca `already at latest version`.
- **Se for Cursor / Codex / só-fetch:** nada a fazer no cache — o próximo fetch
  via `org-context.md` já traz a versão nova. Confirmar só que o URL está na
  lista do brain.
- Nunca reportar a tarefa de "criar/editar skill em org-context" como concluída
  sem confirmar (ou pelo menos tentar) o passo Claude Code **quando a sessão for
  Claude Code**; no Cursor, confirmar o fetch/brain.

## Comandos úteis (só Claude Code)

```bash
claude plugin marketplace list                 # marketplaces conhecidos + estado
claude plugin list                              # plugins instalados e versão em uso
claude plugin marketplace update org-context    # refresca o clone local a partir do remoto
claude plugin update <plugin>@org-context       # actualiza o cache instalado desse plugin
```

## Ver também

- `~/brain/org-context.md` — lista de ficheiros/skills carregados via fetch (canal Cursor).
- `~/brain/MASTER_PROMPT.md` §6–§7 — fetch vs plugins Claude Code.
