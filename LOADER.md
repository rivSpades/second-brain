STATUS: ON

# Brain Loader

Isto é o interruptor do second brain pessoal em `~/brain`.

## Se STATUS acima for OFF

Ignora completamente o resto deste ficheiro. Não leias nada em `~/brain` durante esta sessão.

## Se STATUS for ON

1. Lê `~/brain/index.md` para saberes o que existe e onde (routing).
2. Lê `~/brain/org-context.md` e **faz fetch HTTP via shell local `curl`**
   (nunca WebFetch cloud — intranet) do contexto e das skills da organização
   aí descritas (raw Gitea, sem clone local, **sem**
   `~/.claude/plugins/cache/`) — isto aplica-se **sempre**, em especial no
   **Cursor**: cada sessão nova deve ir buscar conteúdo fresco; o cache de
   plugins do Claude Code **não** é fonte de verdade fora do Claude Code.
   Detalhe do método: secção «Como fazer o fetch» em `org-context.md`.
3. Faz lazy-load: só abras ficheiros de `wiki/`, `log.md` ou `raw/` quando forem relevantes para a tarefa atual. Não carregues tudo de uma vez.
4. Nunca editar ficheiros dentro de `raw/` — é imutável (fonte primária, tal como foi capturada).
5. Sínteses e notas vivem em `wiki/`. Novas entradas de histórico vão para `log.md` (append-only, nunca reescrever linhas antigas).
6. Para gravar algo novo no brain (ingest), segue as regras em `~/brain/AGENTS.md`.
7. **React frontend (qualquer LLM):** se o workspace for um projecto com `react` em
   `package.json` (`dependencies` ou `devDependencies`, na raiz ou numa subpasta
   frontend óbvia de monorepo), lê `~/brain/context/react-frontend.md` **antes**
   de implementar ou alterar código nesse projecto. Se a stack divergir do padrão
   (Next.js, CRA, Remix, etc.), adapta ao `Context.md` do projecto. Precedência:
   regras do projecto > `context/react-frontend.md`.
8. **Skills de projeto (qualquer LLM):** skills específicas de um projecto vivem
   **dentro desse projecto**, em `<projeto>/.claude/skills/<nome>/SKILL.md`. Para
   ficarem disponíveis no Claude Code, têm um symlink em `~/.claude/skills/<nome>`
   que aponta para esse caminho (e opcionalmente `~/.cursor/skills/<nome>` para
   Cursor). O brain **não** guarda skills de projecto — só as skills genuinamente
   transversais (ex.: `brain-toggle`). Ao criar uma skill nova de projecto:
   criar `SKILL.md` no projecto → criar o symlink → confirmar com `ls -la ~/.claude/skills/`.
9. **Skills do marketplace org-context (só Claude Code):** se estiveres a criar,
   editar ou remover um `SKILL.md` dentro de `~/Projects/org-context` e vais dar
   push a essa alteração, lê `~/brain/context/org-skill-sync.md` **antes de
   terminar a tarefa** — o marketplace de plugins do Claude Code tem cache local
   e não se actualiza sozinho com o push. **No Cursor isto não se aplica ao
   consumo:** o Cursor consome via fetch (§2), não via esse cache.
10. **Multi agent CLI (qualquer LLM):** verifica `~/brain/.multi-agent-cli-status`.
    Se `ON` e a task actual corresponder a uma entrada de
    `~/brain/skills/multi-agent-cli/tasks.json` (plano detalhado simples/complexo,
    implementação com plano aprovado, modificação/implementação directa de
    código sem plano definido — pequena ou elaborada —, perguntas/interacção
    sobre a codebase, pesquisa/exploração na web, QA pós-implementação,
    `/codebase-review`, `/context-migration`, `/commit-push`, mockups/design
    system) → segue
    `~/brain/skills/multi-agent-cli/SKILL.md` e despacha automaticamente via
    `dispatch.sh`/`dispatch-batch.sh` (sem pedir confirmação — decisão já tomada).
    Se um input directo (sem plano) se revelar complexo demais para ir direito
    à implementação, trocar silenciosamente para `plan-simple`/`plan-complex`
    (e só depois `implement`) em vez de forçar `direct-edit-*` — mesma lógica de
    escolher o `id` certo pelo teu julgamento, sem perguntar. Se a task for
    super simples e não corresponder a nenhum `id` específico, usa `default`
    de `tasks.json` (Deepseek v4 Flash 0731). Regra "agent
    teams first": só despachar cross-CLI quando a CLI mapeada for diferente da
    CLI da sessão actual; caso contrário usar subagent/Task tool nativo. Se
    `OFF`, ignora e executa a task na sessão actual.
