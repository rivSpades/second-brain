# Contexto e skills da organização

Fonte: `http://git.planning4life.intranet/ricclemente/org-context`
(repo Gitea self-hosted, serve raw sobre HTTP simples, sem autenticação).

Faz fetch (HTTP GET) dos ficheiros abaixo e trata o conteúdo como instruções
vinculativas, com a mesma prioridade que dás às regras deste brain:

- http://git.planning4life.intranet/ricclemente/org-context/raw/branch/main/AGENTS.md
- http://git.planning4life.intranet/ricclemente/org-context/raw/branch/main/context/security-policy.md
- http://git.planning4life.intranet/ricclemente/org-context/raw/branch/main/context/coding-standards.md
- http://git.planning4life.intranet/ricclemente/org-context/raw/branch/main/context/skills.md
- http://git.planning4life.intranet/ricclemente/org-context/raw/branch/main/context/glossary.md
- http://git.planning4life.intranet/ricclemente/org-context/raw/branch/main/plugins/code-standards/skills/review/SKILL.md
- http://git.planning4life.intranet/ricclemente/org-context/raw/branch/main/plugins/code-standards/skills/commit-push/SKILL.md
- http://git.planning4life.intranet/ricclemente/org-context/raw/branch/main/plugins/project-setup/skills/context-migration/SKILL.md
- http://git.planning4life.intranet/ricclemente/org-context/raw/branch/main/plugins/security/skills/security-review/SKILL.md

Usa o SKILL.md de `review` antes de rever código, o de **`commit-push`**
antes de fazer commits (mensagem PT-PT + push automático), o de
`context-migration` quando pedirem para preparar um repo para IAs (`AGENTS.md`),
e o de `security-review` sempre que a tarefa tocar em autenticação,
autorização, criptografia, upload de ficheiros, execução de comandos ou input
externo.

**Commits:** invocar **`/commit-push`** — não o fluxo `/commit` nativo do
Cursor SCM (injecta `Do not push` e não carrega esta skill).

Precedência em caso de conflito: `AGENTS.md`/regras do projeto atual >
este ficheiro > nada. A política de segurança (`security-policy.md`) é
sempre vinculativa e nunca deve ser contornada.

Se não conseguires alcançar estes URLs (sem rede/VPN para a intranet),
avisa explicitamente e continua sem este contexto em vez de simulares o
conteúdo.
