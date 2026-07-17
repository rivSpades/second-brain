# Log (append-only)

Regista aqui uma linha por evento relevante. Nunca apagar ou reescrever linhas antigas — só acrescentar no fim.

- 2026-07-03 — second brain criado (`LOADER.md`, `index.md`, `AGENTS.md`, `raw/`, `wiki/`, `skills/brain-toggle`).
- 2026-07-03 — criado `MASTER_PROMPT.md` (retrato reproduzível do sistema atual: marcadores BRAIN:START/END nos 3 ponteiros, `org-context.md` remoto + espelho como plugins Claude Code, convenção skills fonte-única + symlink, brain-toggle soft/hard). Lint em `AGENTS.md` passa a exigir atualizá-lo sempre que a estrutura mudar.
- 2026-07-07 — regras React frontend em `context/react-frontend.md` + `LOADER.md` §7 (cross-tool); removido plugin Cursor-only.
- 2026-07-07 — removida skill `react-frontend` (era contexto, não skill).
- 2026-07-07 — `AGENTS.md`: secção «Contexto vs skills» + regra cross-tool; lint §5.
- 2026-07-08 — skill org `commit` renomeada para `commit-push` (evita colisão com SCM Cursor); `org-context.md` e `MASTER_PROMPT.md` actualizados; hook `beforeSubmitPrompt` bloqueia template SCM nativo.
- 2026-07-08 — `org-context`: `context/skills.md` (eliminar skill = remover todo o rastro); fetch em `org-context.md`.
- 2026-07-08 — criada skill org `commit-push`, mas marketplace do Claude Code ficou desactualizado (preso no commit de instalação, 2026-07-03) e a skill não apareceu; corrigido com `claude plugin marketplace update org-context` + `claude plugin update code-standards@org-context`. Nova regra cross-tool `context/org-skill-sync.md` + `LOADER.md` §8 + `MASTER_PROMPT.md` §7 (renumerado §7→§10) para tornar este passo automático da próxima vez.
- 2026-07-17 — `~/brain` clonado de fresco numa nova máquina/ambiente; recriados os 3 ponteiros (`~/AGENTS.md`, `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`) via `brain-toggle on --hard`, symlink `~/.claude/skills/brain-toggle`, e regra de auto-symlink em `~/.claude/CLAUDE.md` (MASTER_PROMPT.md §5). Marketplace `org-context` **não** instalado: `git.planning4life.intranet` inacessível neste sandbox (sem VPN) — pendente, correr manualmente quando na rede certa. Corrigida nota desactualizada em `MASTER_PROMPT.md` §10 (`~/brain` já é repo git).
