# Index — Second Brain

Routing: onde procurar o quê. Lê isto primeiro, depois faz lazy-load só do que for relevante.

| Área | Onde | Notas |
|---|---|---|
| React frontend (padrão cross-tool) | `context/react-frontend.md` | Carregado via `LOADER.md` §7 quando `react` está no `package.json` |
| Sincronização de skills org-context (Claude Code) | `context/org-skill-sync.md` | Carregado via `LOADER.md` §8 ao criar/editar/dar push a um `SKILL.md` em `~/Projects/org-context` |
| _(ainda vazio)_ | `wiki/` | Preenche uma linha por tópico à medida que sintetizas material de `raw/` |

## Ver também

- `MASTER_PROMPT.md` — retrato reproduzível de todo o sistema (brain + ponteiros + skills + plugins). Atualizado sempre que a estrutura mudar (ver lint em `AGENTS.md`).
- `AGENTS.md` — regras de ingest/query/lint; **contexto vs skills** (secção dedicada).
- `org-context.md` — contexto e skills da organização (carregado sempre, via `LOADER.md`, não lazy).
- `context/` — regras cross-tool por stack (ex.: `react-frontend.md`); ver `LOADER.md` §7.
- `log.md` — histórico append-only de eventos.
- `raw/` — fontes imutáveis, nunca editadas.
- `wiki/` — sínteses derivadas de `raw/`.
