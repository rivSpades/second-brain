# Contexto do projeto

## Propósito

`brain` é o second brain pessoal do Ricardo: contexto cross-tool, skills
invocáveis e ponteiros globais para Claude Code, Codex, Cursor e OpenCode.

## Stack

- Markdown e shell POSIX
- Git
- Integrações locais com `~/brain`, `~/.claude`, `~/.codex`, `~/.cursor` e
  `~/.config/opencode`
- Contexto organizacional servido por raw HTTP a partir do Gitea interno

## Mapa de documentação

- `AGENTS.md` — regras de ingestão, consulta e distinção entre contexto e
  skills.
- `LOADER.md` — carregamento do brain e dos recursos do `org-context`.
- `org-context.md` — fonte e URLs canónicos do contexto e skills da organização.
- `MASTER_PROMPT.md` — arquitetura reproduzível do sistema completo.
- `context/` — contexto especializado, incluindo sincronização de skills.
- `skills/` — skills pessoais do brain.
- `scripts/` — automações cross-tool do brain.
