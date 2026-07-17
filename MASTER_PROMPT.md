# Master Prompt — Second Brain + config cross-tool

> Este ficheiro é a fonte de verdade para recriar, do zero ou por integração,
> todo o sistema pessoal de contexto (`~/brain` + ponteiros em `~/.claude`,
> `~/.codex`, `~`). É auto-manutenido: sempre que a estrutura de `~/brain` ou
> `~/.claude` mudar (nova skill, novo ponteiro, novo plugin, novo mecanismo de
> toggle, etc.), este ficheiro tem de ser atualizado no mesmo momento — ver
> regra em `AGENTS.md` § Lint. Não editar `log.md` para descrever a
> arquitetura; `log.md` é só histórico de eventos. Este ficheiro é o
> retrato atual.

Última sincronização: 2026-07-17.

## 0 · Princípio

Um second brain pessoal, portável entre máquinas e entre ferramentas de IA
(Claude Code, Codex, outras via `AGENTS.md`), com um interruptor ON/OFF
central e uma única fonte de contexto organizacional remota. Se já existir
algo ao correr este prompt numa máquina nova, integra sem apagar.

**Contexto ≠ skill** (ver `AGENTS.md` § Contexto vs skills):

- **Contexto** — `context/*.md`, carregado via `LOADER.md`; regras e padrões.
- **Skill** — `skills/*/SKILL.md`; fluxos invocáveis.
- **Cross-tool** — ambos vivem em `~/brain/` e chegam a qualquer LLM pelos
  3 ponteiros; nunca só numa ferramenta (ex.: plugin Cursor-only).

## 1 · Interruptor

`~/brain/LOADER.md` — 1ª linha é `STATUS: ON` ou `STATUS: OFF`.

- Se `STATUS: OFF` → o agente ignora completamente o resto de `~/brain`
  nesta sessão.
- Se `STATUS: ON` → o agente:
  1. Lê `~/brain/index.md` (routing).
  2. Lê `~/brain/org-context.md` e carrega o contexto remoto aí descrito
     (sempre, não é lazy).
  3. Faz lazy-load de `wiki/`, `log.md`, `raw/` só quando relevante.
  4. Nunca edita `raw/`.

## 2 · Ligação aos pontos de entrada (3 ponteiros)

Fonte única: só `~/brain/LOADER.md` muda; os ponteiros nunca precisam de
segundo toque manual. Cada um dos 3 ficheiros abaixo contém um bloco
marcado (não um `@import` nu — os marcadores permitem ao `brain-toggle`
remover/repor o import em modo hard):

```
<!-- BRAIN:START -->
@~/brain/LOADER.md
<!-- BRAIN:END -->
```

Ficheiros ponteiro:
- `~/.claude/CLAUDE.md`
- `~/.codex/AGENTS.md`
- `~/AGENTS.md`

`~/.claude/CLAUDE.md` tem ainda, fora do bloco BRAIN, a regra de
sincronização de skills (ver § 5).

## 3 · Estrutura de `~/brain/`

```
brain/
├── LOADER.md        # interruptor (§1)
├── MASTER_PROMPT.md  # este ficheiro
├── AGENTS.md         # regras ingest/query/lint
├── index.md          # routing — lido sempre que STATUS=ON
├── log.md            # histórico append-only, nunca reescrever linhas antigas
├── org-context.md     # contexto remoto da organização (§6) — carregado sempre
├── context/           # regras cross-tool por stack/tópico (§7, §9) — org-skill-sync.md, react-frontend.md
├── raw/              # fontes imutáveis, nunca editadas depois de gravadas
├── wiki/              # sínteses derivadas de raw/, uma entrada por tópico
└── skills/            # skills pessoais, fonte de verdade (§5)
```

Regras (`AGENTS.md`):
- **Ingest**: material novo entra em `raw/` tal como veio (imutável depois).
  Depois, cria/atualiza a síntese em `wiki/` e regista uma linha em
  `log.md`. Atualiza `index.md` para apontar para a entrada nova.
- **Query**: lê sempre `index.md` primeiro; lazy-load do resto; nunca
  editar `raw/`, mesmo em query.
- **Lint** (antes de fechar uma sessão de ingest, confirmar):
  1. `index.md` aponta para qualquer síntese nova em `wiki/`.
  2. `log.md` tem entrada nova.
  3. Nada foi editado/apagado em `raw/`.
4. Se a estrutura de `~/brain` ou `~/.claude` mudou nesta sessão (nova
     skill, novo ponteiro, novo ficheiro em `context/`, novo modo de toggle) →
     `MASTER_PROMPT.md` foi atualizado a refletir isso.
  5. Novo contexto ou skill segue `AGENTS.md` § Contexto vs skills.

## 4 · Contexto vs skills

Ver tabela completa em `AGENTS.md`. Resumo:

| Contexto | Skill |
|----------|-------|
| `context/<nome>.md` | `skills/<nome>/SKILL.md` |
| Carregado por `LOADER.md` | Invocado (`/nome`) ou autoinvocação |
| Padrões, regras, stack | Acções e fluxos |

**Cross-tool obrigatório** para ambos — fonte em `~/brain/`, entrega via
ponteiros `AGENTS.md` / `CLAUDE.md` / `LOADER.md`. Não duplicar contexto
como skill; não colocar contexto em `.cursor/plugins/` ou User Rules só-Cursor.

## 5 · Skills pessoais (fonte única + symlink)

`~/brain/skills/` é a fonte de verdade de todas as skills pessoais.
`~/.claude/skills/` contém apenas symlinks — nunca ficheiros diretos.

Regra em `~/.claude/CLAUDE.md` (fora do bloco BRAIN, porque é uma regra do
Claude Code especificamente, não do brain):
- Ao iniciar sessão: verificar se há pasta em `~/brain/skills/` sem
  symlink correspondente em `~/.claude/skills/`; se sim, criar
  (`ln -s ~/brain/skills/<nome> ~/.claude/skills/<nome>`).
- Ao criar skill nova: criar `~/brain/skills/<nome>/SKILL.md` (frontmatter
  `name` + `description`), symlink imediato, confirmar com `ls -la`.

Skill actual: `brain-toggle` (ver §8). Commits org: **`/commit-push`** (ver `org-context.md` → skill `commit-push`).

## 6 · Contexto da organização (`org-context.md`)

Fonte remota: `http://git.planning4life.intranet/ricclemente/org-context`
(Gitea self-hosted, raw HTTP sem autenticação). `org-context.md` lista os
URLs a fazer fetch (AGENTS.md, security-policy.md, coding-standards.md,
glossary.md, skills.md, e os SKILL.md de review/**commit-push**/context-migration/
security-review) e instrui a tratá-los como vinculativos.

Precedência em conflito: regras do projeto atual > `org-context.md` >
nada. `security-policy.md` nunca é contornável.

Se os URLs não forem alcançáveis (sem VPN/rede), avisar e continuar sem
esse contexto — nunca simular o conteúdo.

**Espelho como plugins do Claude Code**: o mesmo repo `org-context` está
também instalado como marketplace de plugins (`extraKnownMarketplaces` em
`~/.claude/settings.json`, source git para o mesmo repo), com 3 plugins
habilitados em `enabledPlugins`:
- `code-standards@org-context` → skills `commit-push`, `review`
- `project-setup@org-context` → skill `context-migration`
- `security@org-context` → skill `security-review`

Isto dá as mesmas skills tanto via fetch HTTP direto (para agentes sem
suporte a plugins, ex. Codex) como via mecanismo nativo de plugins do
Claude Code (autoinvocação por descrição, sem precisar de fetch manual).
Ao recriar num Claude Code novo: instalar o marketplace
`org-context` (`git.planning4life.intranet/ricclemente/org-context.git`) e
habilitar os 3 plugins acima.

## 7 · Sincronização de skills org-context (plugin marketplace)

Regra completa em `context/org-skill-sync.md`, disparada por `LOADER.md` §8.

Skills publicadas em `org-context` chegam por dois canais independentes (ver §6): fetch
HTTP directo (sempre fresco, qualquer LLM) e o clone/cache local do marketplace de
plugins do Claude Code (`claude plugin install`). O segundo **não se actualiza
sozinho** — fica preso na versão instalada até correr
`claude plugin marketplace update org-context` + `claude plugin update <plugin>@org-context`.

Regra: sempre que se cria, edita ou remove um `SKILL.md` em `~/Projects/org-context` e
se dá push, se a sessão for Claude Code com o plugin instalado, correr os dois comandos
acima e avisar que é preciso reiniciar a sessão. Caso contrário (outro LLM, ou consumo
só via fetch), nada a fazer — o próximo fetch já traz a versão nova.

## 8 · `brain-toggle` (soft / hard)

`~/brain/skills/brain-toggle/SKILL.md` + `scripts/toggle.sh`.

- **soft** (default): só troca `STATUS: ON`/`OFF` na 1ª linha de
  `LOADER.md`. Os 3 ponteiros continuam a importar — depende do agente
  respeitar a regra "se OFF, ignora tudo".
- **hard**: além do soft, remove (`off --hard`) ou repõe (`on --hard`) o
  bloco `BRAIN:START/END` inteiro dos 3 ponteiros. Sem o bloco,
  `~/brain` não entra em contexto de todo, mesmo que o agente ignore a
  regra do STATUS.
- `status`: mostra `STATUS:` de `LOADER.md` + se cada ponteiro tem o
  bloco hard presente ou não.

Comandos: `~/brain/skills/brain-toggle/scripts/toggle.sh {on|off|status} [--hard]`.

## 9 · Contexto React frontend (cross-tool)

Padrão para projectos React — **qualquer LLM** que importe o brain via
ponteiros (`~/AGENTS.md`, `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`):

| Ficheiro | Função |
|----------|--------|
| `context/react-frontend.md` | Fonte canónica das regras (stack, data layer, UI, etc.) |
| `LOADER.md` §7 | Instrução de carregar `context/react-frontend.md` quando `react` está no `package.json` |

- **Activação:** `react` em `package.json`; adaptar ao `Context.md` se stack divergir.
- **Precedência:** regras do projecto > `context/react-frontend.md`.
- **Espelho legado:** `~/Projects/React/p4l_platform/docs/GENERIC_CURSOR_AGENT_RULES.md` (aponta para o brain; não duplicar edições lá).

Ao recriar numa máquina nova: garantir pasta `context/` com `react-frontend.md` e `LOADER.md` §7.

## 10 · Fecho / verificação

`~/brain` é o próprio repositório git (`rivSpades/second-brain` no
GitHub) — portável entre máquinas por `git clone`/`pull`, não por cópia
manual. `~` continua a não ser um repositório git. Se `~/brain` alguma
vez passar a viver dentro de outro repo (ex. como submódulo ou pasta de
um monorepo), adicionar `brain/` ao `.gitignore` desse repositório
contentor e atualizar este ficheiro a registar essa mudança.

Como confirmar que está ativo:
- Perguntar ao agente "qual é o STATUS do brain?" (deve responder ON/OFF
  lendo `LOADER.md`).
- Correr `~/brain/skills/brain-toggle/scripts/toggle.sh status`.
- Ver `/context` no Claude Code e confirmar que `~/brain/LOADER.md` e
  `org-context.md` aparecem carregados.
