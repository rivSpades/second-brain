# Regras do Second Brain

## Contexto vs skills

**Não confundir** — são mecanismos diferentes:

| | **Contexto** | **Skill** |
|---|-------------|-----------|
| **O quê** | Regras, padrões e conhecimento que o agente deve seguir | Fluxo ou acção invocável (ex.: toggle, commit) |
| **Onde** | `context/<nome>.md` (+ `org-context.md` na raiz) | `skills/<nome>/SKILL.md` |
| **Como entra em sessão** | `LOADER.md` manda carregar (condicional ou sempre) | Invocação explícita (`/nome`) ou autoinvocação da ferramenta |
| **Registo** | `index.md` + passo em `LOADER.md` | `index.md` opcional; symlink `~/.claude/skills/` se Claude |

**Regra cross-tool:** sempre que criares **contexto** ou **skill**, tem de ser compatível com **qualquer LLM** (Cursor, Claude Code, Codex, etc.) via os ponteiros globais (`~/AGENTS.md`, `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md` → `LOADER.md`). Proibido:

- Contexto só em plugin Cursor, User Rules só-Cursor, ou `skills/` (contexto não é skill).
- Skill que seja na prática contexto estático (move para `context/`).
- Depender de formato ou API exclusiva de uma ferramenta sem fonte legível em `~/brain/`.

Contexto → `context/` + `LOADER.md`. Skill → `skills/` + invocação. Nunca misturar.

## Ingest

- Material novo e não processado entra em `raw/` tal como veio. Depois de gravado, `raw/` é imutável — nunca editar nem apagar ficheiros lá dentro.
- Depois de gravar em `raw/`, cria ou atualiza a síntese correspondente em `wiki/` e regista uma linha em `log.md`.
- Atualiza `index.md` para apontar para qualquer entrada nova em `wiki/`.

## Query

- Lê sempre `index.md` primeiro para saberes onde procurar.
- Lazy-load: só abras ficheiros de `wiki/`, `context/`, `raw/` ou `log.md` quando forem relevantes para a tarefa actual — excepto `context/react-frontend.md`, que o `LOADER.md` §7 manda carregar em projectos React.
- Nunca editar ficheiros em `raw/`, mesmo em modo query.

## Lint

Antes de fechar uma sessão de ingest, confirma:

1. `index.md` aponta para qualquer síntese nova em `wiki/`.
2. `log.md` tem uma entrada nova (append-only, nunca reescrever linhas antigas).
3. Nada foi editado ou apagado em `raw/`.
4. Se a estrutura de `~/brain` ou `~/.claude` mudou nesta sessão (nova skill, novo ponteiro, novo ficheiro em `context/`, novo modo do `brain-toggle`, nova regra global), atualiza `MASTER_PROMPT.md` para refletir isso — esse ficheiro é o retrato reproduzível do sistema todo, não pode ficar desatualizado.
5. Novo **contexto** ou **skill** segue `AGENTS.md` § Contexto vs skills (cross-tool; não confundir os dois).
