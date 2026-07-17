STATUS: ON

# Brain Loader

Isto é o interruptor do second brain pessoal em `~/brain`.

## Se STATUS acima for OFF

Ignora completamente o resto deste ficheiro. Não leias nada em `~/brain` durante esta sessão.

## Se STATUS for ON

1. Lê `~/brain/index.md` para saberes o que existe e onde (routing).
2. Lê `~/brain/org-context.md` e carrega o contexto e as skills da
   organização aí descritas (fetch via link, sem clone local) — isto
   aplica-se sempre, independentemente do projeto ou da ferramenta de IA.
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
8. **Skills do marketplace org-context (qualquer LLM, acção só relevante em Claude
   Code):** se estiveres a criar, editar ou remover um `SKILL.md` dentro de
   `~/Projects/org-context` e vais dar push a essa alteração, lê
   `~/brain/context/org-skill-sync.md` **antes de terminar a tarefa** — o marketplace
   de plugins do Claude Code tem cache local e não se actualiza sozinho com o push.
