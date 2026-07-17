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
| Fetch via link (`org-context.md`, qualquer LLM — Cursor, Codex, etc.) | HTTP GET directo ao raw do ficheiro, a cada sessão | **Sim** — o próximo fetch já traz a versão nova |
| Plugin/marketplace nativo do Claude Code (`claude plugin install`) | Clone git local em `~/.claude/plugins/marketplaces/org-context` + cache versionado por plugin em `~/.claude/plugins/cache/` | **Não** — fica preso na versão/commit em que foi instalado ou actualizado pela última vez, de propósito (evita que o comportamento de uma sessão mude a meio só porque alguém deu push a um repo partilhado) |

## Regra

Depois de dar push a uma alteração de skill em `org-context`:

- **Antes de tudo, subir a versão em `plugins/<plugin>/.claude-plugin/plugin.json`**
  (patch bump, ex. `1.0.1` → `1.0.2`) **e dar commit+push a essa alteração também**.
  `claude plugin update` compara só o número de versão contra o cache instalado — se o
  `SKILL.md` mudou mas a versão ficou igual, o comando responde
  `already at latest version` e **não** actualiza o conteúdo do cache, mesmo depois do
  `marketplace update` já ter o ficheiro novo no clone local. Sem este bump, os passos
  seguintes são um no-op silencioso — confirmado na prática em 2026-07-14.
- **Se a sessão actual for Claude Code** e o plugin em causa estiver instalado via
  marketplace (confirmar com `claude plugin list`): correr imediatamente
  ```bash
  claude plugin marketplace update org-context
  claude plugin update <plugin>@org-context   # ex.: code-standards@org-context
  ```
  e avisar explicitamente que é preciso **reiniciar a sessão Claude Code** para a skill
  nova/alterada aparecer (a própria CLI confirma isto com "Restart to apply changes").
  - Confirmar que o update foi real (não no-op): a saída deve dizer
    `updated from X to Y`, nunca `already at latest version`. Se disser isto último e
    sabes que o conteúdo mudou, falta o bump de versão no passo anterior — corrigir e
    repetir.
  - Verificação opcional: `grep` por uma frase nova do diff dentro de
    `~/.claude/plugins/cache/org-context/<plugin>/<versão>/...` para confirmar que o
    conteúdo instalado é mesmo o novo.
- **Se for outro LLM/ferramenta** (Cursor, Codex, ou um Claude Code que só consome via
  fetch e não tem o plugin instalado): não é preciso nenhuma acção — o próximo fetch a
  `org-context.md` já traz o conteúdo actualizado.
- Nunca reportar a tarefa de "criar/editar skill em org-context" como concluída sem
  confirmar (ou pelo menos tentar) este passo quando aplicável.

## Comandos úteis

```bash
claude plugin marketplace list                 # marketplaces conhecidos + estado
claude plugin list                              # plugins instalados e versão em uso
claude plugin marketplace update org-context    # refresca o clone local a partir do remoto
claude plugin update <plugin>@org-context       # actualiza o cache instalado desse plugin
```

## Ver também

- `~/brain/org-context.md` — lista de ficheiros/skills carregados via fetch.
- `~/brain/MASTER_PROMPT.md` §7 — espelho do org-context como plugins Claude Code.
