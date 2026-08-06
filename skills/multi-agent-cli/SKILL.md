---
name: multi-agent-cli
description: Orquestra tasks para subagents em CLIs de IA especificas (opencode, claude, cursor-agent) mapeadas por tipo de task e modelo, mesmo quando essa CLI é diferente da sessão actual. Usa quando a task actual corresponder a uma entrada em tasks.json — plano detalhado de feature simples ou complexa, plano detalhado de um projecto inteiro do zero, implementação de código com plano já aprovado, modificação/implementação directa de código sem plano definido (pequena ou elaborada), perguntas/interacção sobre a codebase, pesquisa/exploração na web, QA depois de implementação, skill /codebase-review, skill /context-migration, skill /commit-push, desenho de mockups/design system, ou gestão de regras de contexto/skills/second brain. Também invocável manualmente ("usa o multi agent cli para..."). Toggle em ~/brain/.multi-agent-cli-status.
---

# multi-agent-cli

Orquestrador cross-tool de subagentes. Delega tasks específicas para a combinação
CLI + modelo que o utilizador definiu como melhor para esse tipo de trabalho —
mesmo que essa CLI seja diferente da sessão actual (Cursor, Claude Code, OpenCode,
Codex, ...). O mapping vive uma única vez em `tasks.json` e chega a qualquer CLI
pelos symlinks já estabelecidos — nunca duplicar nem redefinir noutro sítio.

## Toggle

`~/brain/.multi-agent-cli-status` — `ON` ou `OFF`.

```bash
~/brain/skills/multi-agent-cli/scripts/toggle.sh on
~/brain/skills/multi-agent-cli/scripts/toggle.sh off
~/brain/skills/multi-agent-cli/scripts/toggle.sh status
```

Se `OFF`: ignora esta skill por completo — executa a task na sessão actual como
farias normalmente. `dispatch.sh`/`dispatch-batch.sh` recusam-se a correr enquanto
o toggle estiver `OFF` (falha rápido, não silenciosamente).

## Fonte única do mapping

[`tasks.json`](tasks.json) — cross-tool por construção: chega a qualquer CLI
através dos symlinks (todos apontam para o mesmo ficheiro em `~/brain/`):

| CLI | Symlink |
|---|---|
| Claude Code | `~/.claude/skills/multi-agent-cli` |
| OpenCode | `~/.config/opencode/skills/multi-agent-cli` |
| Cursor | `~/.cursor/skills/multi-agent-cli` |
| Codex | `~/.codex/skills/multi-agent-cli` |

Cada entrada:

```json
{
  "id": "plan-simple",
  "description": "...",
  "write_mode": "read-only",
  "primary": { "cli": "opencode", "model": "Muse Spark 1.2", "slug": "openrouter/meta/muse-spark-1.2" },
  "fallback": null
}
```

## Regra "agent teams first" (não negociável)

Subagents nativos e agent teams (Task tool, `@subagent`, equipas experimentais do
OpenCode) **continuam a ser a via preferida**. Este orquestrador só entra em jogo
quando:

1. A CLI mapeada (`primary.cli` ou `fallback.cli`) é **diferente** da CLI da
   sessão actual, ou
2. O modelo mapeado só está acessível fora da sessão actual (ex.: a sessão actual
   não tem esse provider/modelo configurado).

Se a CLI mapeada == CLI actual e o modelo já está disponível nativamente → usar o
subagent/Task tool nativo, **não** `dispatch.sh`. Isto preserva paralelismo nativo
e contexto partilhado sempre que possível; o dispatch cross-CLI é reservado a
quando é mesmo preciso saltar de processo/CLI.

## Disparo automático

Sempre que a task actual corresponder a uma entrada de `tasks.json` (pelo `id` ou
pela descrição/`match`), despachar **sem pedir confirmação** ao utilizador —
decisão já confirmada com o utilizador. Reportar o resultado (sucesso, fallback ou
simulado) na resposta final, nunca em silêncio.

## Uso — task única

```bash
~/brain/skills/multi-agent-cli/scripts/dispatch.sh \
  --task plan-simple \
  --prompt "<pedido completo, com contexto suficiente para o subagent trabalhar isolado>" \
  [--cwd /path/do/projecto] \
  [--simulate]
```

Escolhe sempre o `--task <id>` correcto com o teu próprio julgamento (não há
fuzzy-matching automático em bash) — `tasks.json` é só a fonte de verdade dos
dados, não um motor de matching. Imprime o caminho do `result_file` (JSON).
**Lê sempre esse ficheiro** antes de responder ao utilizador — nunca inventar o
resultado.

Se a task for super simples e não corresponder a nenhum outro `id` da lista,
usa `--task default` (hoje: opencode / Deepseek v4 Flash 0731) em vez de
forçar um `id` que não encaixa. Ex.: `/commit-push` cai neste catch-all.

## Uso — várias tasks em paralelo

```bash
~/brain/skills/multi-agent-cli/scripts/dispatch-batch.sh \
  --cwd /path/do/projecto \
  --task plan-simple:"<prompt 1>" \
  --task qa:"<prompt 2>"
```

Lança cada task em paralelo (background + `wait`), agrega tudo num
`_batch-summary.json` no mesmo directório de run. Usar quando houver tasks
independentes que não dependem do resultado umas das outras (ex.: plano de uma
feature + QA de outra feature em simultâneo).

## Cadeia de fallback (dentro de `dispatch.sh`)

1. CLI + modelo **primário** real (`opencode run` / `claude -p` / `cursor-agent -p`,
   sempre não-interactivo).
2. Se falhar (binário ausente, exit≠0, timeout, modelo inválido) e existir
   `fallback` em `tasks.json` → repete com a alternativa. Resultado marca
   `"fallback": true`.
3. Se tudo falhar (ou `--simulate` explícito) → stub `/bin/echo`, resultado marca
   `"status": "simulated"` — nunca `"status": "ok"`. O agente principal deve
   tratar isto como "a task não foi executada de facto" e decidir se a faz ele
   próprio na sessão actual.

## Resultado

Cada dispatch escreve `~/brain/.multi-agent-cli/<timestamp>-<hash8>/<task_id>.json`:

```json
{
  "task_id": "...", "cli": "...", "model": "...", "status": "ok|error|simulated",
  "exit_code": 0, "stdout": "...", "stderr": "...", "fallback": false,
  "simulated": false, "binary": "...", "command": ["..."],
  "duration_seconds": 0.0, "result_file": "..."
}
```

`dispatch-batch.sh` escreve ainda `_batch-summary.json` no directório partilhado,
com um array dos `result_file` de cada task da mesma batch.

## Tasks mapeadas (ver `tasks.json` para os valores exactos)

| Task | Primário | Alternativa |
|---|---|---|
| `default` (catch-all, super simples, incl. `/commit-push`) | opencode / Deepseek v4 Flash 0731 | — |
| `codebase-questions` | opencode / GPT-5.6 Luna | — |
| `plan-simple` | opencode / Muse Spark 1.2 | — |
| `plan-complex` | opencode / Qwen3.8 Max | — |
| `implement` | opencode / GPT-5.6 Luna | — |
| `websearch-exploration` | opencode / Deepseek v4 Pro (xHigh) | — |
| `direct-edit-small` | opencode / Deepseek v4 Flash 0731 | — |
| `direct-edit-elaborate` | opencode / GPT-5.6 Luna | — |
| `qa` | claude / Claude Sonnet 5 | opencode / Gemini 3.1 Pro |
| `codebase-review` | claude / Claude Sonnet 5 | opencode / Gemini 3.1 Pro |
| `context-migration` | opencode / Qwen3.8 Max | — |
| `mockup-design` | claude / Opus 5 (max) | opencode / Kimi k3 Max |
| `plan-from-scratch` | claude / Opus 5 (max) | — |
| `context-skill-brain-mgmt` | claude / Claude Sonnet 5 | — |

## Não fazer

- Não duplicar o mapping fora de `tasks.json` — editar só ali.
- Não despachar cross-CLI quando a CLI mapeada == CLI actual e o modelo está
  disponível nativamente — usar subagent nativo.
- Não reportar um resultado de `dispatch.sh`/`dispatch-batch.sh` sem ler o(s)
  `result_file`.
- Não marcar `status:"ok"` num run simulado.
- Não escrever no workspace (`write_mode:"workspace"`) fora do `--cwd`
  explicitamente passado.
- Não pedir confirmação antes de despachar quando a task corresponde ao mapping
  — o disparo é automático (decisão já tomada com o utilizador).
