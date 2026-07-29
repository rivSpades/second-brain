# Contexto e skills da organização

Fonte: `http://git.planning4life.intranet/ricclemente/org-context`
(repo Gitea self-hosted, serve raw sobre HTTP simples, sem autenticação).

## Arranque de sessão (obrigatório)

1. Faz **HTTP GET** de **todos** os URLs abaixo **neste turno de arranque**
   (ou no primeiro turno em que o brain estiver ON). Não uses cópias locais,
   clones, nem ficheiros em disco como substituto.
2. Trata o conteúdo obtido como instruções vinculativas, com a mesma prioridade
   que dás às regras deste brain.

### Como fazer o fetch (obrigatório — Cursor / intranet)

Hosts `*.planning4life.intranet` (e equivalentes de intranet) **não** são
alcançáveis pelo **WebFetch** / fetch cloud do Cursor (falha tipicamente com
503 / timeout).

- **Usar sempre** shell local, tipicamente:
  ```bash
  curl -fsSL --max-time 30 'http://git.planning4life.intranet/.../ficheiro.md'
  ```
- **Proibido:** WebFetch, `WebFetch`, MCP web-fetch, ou qualquer HTTP que saia
  da sandbox cloud para estes hosts.
- **Permitido:** `curl` / `wget` / Python `urllib` na ferramenta **Shell** da
  máquina (WSL / host local).
- O mesmo vale para stubs em `~/.cursor/skills/*/SKILL.md` e para qualquer
  GET fresco a skills/contexto do `org-context` durante a sessão.

### Proibido (Cursor e qualquer LLM sem marketplace Claude)

- **Nunca** abrir, ler ou seguir skills em
  `~/.claude/plugins/cache/org-context/**` — é cache do Claude Code, fica
  desactualizado de propósito e **não** é fonte de verdade no Cursor.
- **Nunca** tratar um path em `available_skills` / agent skills que aponte para
  esse cache como a skill a executar. Se o IDE injectar esses paths, **ignora-os**
  e faz fetch dos URLs raw abaixo.
- **Nunca** usar `~/.claude/plugins/marketplaces/org-context` como fonte de
  conteúdo de skill no Cursor.

O canal canónico no Cursor (e Codex, e qualquer LLM só-com-fetch) é **só** o
HTTP raw listado aqui. O cache/marketplace Claude Code existe **apenas** para
sessões Claude Code com plugins instalados.

### Cursor — corte mecânico do cache (obrigatório na máquina)

Regras no brain **não bastam**: o Cursor injecta skills de
`~/.claude/plugins/cache/` quando o import third-party está ligado.

1. **Cursor Settings → Rules, Skills, Subagents** → desligar
   **«Include third-party Plugins, Skills, and other configs»**.
2. Skills org no menu `/` vêm de stubs em `~/.cursor/skills/<nome>/SKILL.md`
   (só descoberta). O stub manda fazer fetch do URL raw antes de executar.
3. **Nova sessão** de chat (esta sessão já pode ter o cache injectado).

Sem o passo 1, o IDE continua a listar paths do cache Claude em
`available_skills` mesmo com este ficheiro actualizado.

## URLs a fazer fetch

- http://git.planning4life.intranet/ricclemente/org-context/raw/branch/main/AGENTS.md
- http://git.planning4life.intranet/ricclemente/org-context/raw/branch/main/context/security-policy.md
- http://git.planning4life.intranet/ricclemente/org-context/raw/branch/main/context/coding-standards.md
- http://git.planning4life.intranet/ricclemente/org-context/raw/branch/main/context/skills.md
- http://git.planning4life.intranet/ricclemente/org-context/raw/branch/main/context/glossary.md
- http://git.planning4life.intranet/ricclemente/org-context/raw/branch/main/plugins/code-standards/skills/review/SKILL.md
- http://git.planning4life.intranet/ricclemente/org-context/raw/branch/main/plugins/code-standards/skills/commit-push/SKILL.md
- http://git.planning4life.intranet/ricclemente/org-context/raw/branch/main/plugins/project-setup/skills/context-migration/SKILL.md
- http://git.planning4life.intranet/ricclemente/org-context/raw/branch/main/plugins/security/skills/security-review/SKILL.md
- http://git.planning4life.intranet/ricclemente/org-context/raw/branch/main/plugins/codebase-review/skills/codebase-review/SKILL.md
- http://git.planning4life.intranet/ricclemente/org-context/raw/branch/main/plugins/openproject/skills/create-ticket/SKILL.md
- http://git.planning4life.intranet/ricclemente/org-context/raw/branch/main/plugins/openproject/skills/review-tickets/SKILL.md

## Quando usar cada skill

Usa o SKILL.md de `review` antes de rever código, o de **`commit-push`**
antes de fazer commits (mensagem PT-PT + push automático), o de
`context-migration` quando pedirem para preparar um repo para IAs (`AGENTS.md`),
o de `security-review` sempre que a tarefa tocar em autenticação,
autorização, criptografia, upload de ficheiros, execução de comandos ou input
externo, o de `codebase-review` para auditoria completa de codebase, e
**`create-ticket`** / **`review-tickets`** para OpenProject (criar tickets
high-level ou executar tasks «Aprovada para produção»; requer `OPENPROJECT_*`
no `.env` do projecto).

**Commits:** invocar **`/commit-push`** — não o fluxo `/commit` nativo do
Cursor SCM (injecta `Do not push` e não carrega esta skill). Ao executar a
skill, o conteúdo vinculativo é o do **curl local** acima (não um SKILL.md em
cache).

Precedência em caso de conflito: `AGENTS.md`/regras do projeto atual >
este ficheiro > nada. A política de segurança (`security-policy.md`) é
sempre vinculativa e nunca deve ser contornada.

Se o `curl` falhar (sem rede/VPN para a intranet), avisa explicitamente e
continua sem este contexto em vez de simulares o conteúdo — e **não** tentes
WebFetch como fallback.
