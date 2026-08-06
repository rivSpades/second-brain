# React frontend — detalhe (overflow)

> Overflow de `react-frontend.md`: formulários/wizards (§8), setup mobile (§9a),
> anti-duplicação (§9b), loading/UX (§15). Ler só quando a tarefa tocar nestes
> temas.

## Formulários e wizards

Padrão multi-passo recomendado:

1. Passos com ids estáveis (`categoria`, `tipo`, `identificação`, …).
2. Seleção visual com componentes reutilizáveis do design system (`SelectableOptionTile`, `SelectableOptionCard`, etc.).
3. Header com voltar/fechar + acções de passo no rodapé (Continuar / Guardar).
4. Validação por passo antes de avançar; validação completa no submit.
5. Ecrã de sucesso com acções opcionais (ex.: configurar alertas).

Campos obrigatórios do payload: conforme `docs/{DOMAIN}_API.md`.

## Setup mobile obrigatório — `public/index.html`

Em qualquer projeto mobile-first, o `index.html` **deve** ter:

1. **Meta viewport com zoom bloqueado:**
   ```html
   <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no, viewport-fit=cover" />
   ```

2. **JS listeners para iOS** (iOS 10+ ignora `user-scalable=no`):
   ```html
   <script>
     document.addEventListener('gesturestart', function (e) { e.preventDefault(); });
     document.addEventListener('touchmove', function (e) { if (e.scale !== 1) e.preventDefault(); }, { passive: false });
   </script>
   ```

Verificar estes dois pontos em qualquer projeto React mobile-first, antes de qualquer tarefa de UI. Se estiverem em falta, corrigir sem precisar de ser pedido.

## Reutilização de componentes — regra absoluta

**Se o mesmo componente visual aparece em 2 ou mais lugares, NÃO pode estar
duplicado.** Código duplicado para o mesmo visual é sempre um erro de arquitectura,
independentemente do domínio.

**Antes de criar qualquer componente novo:**

1. Grep em `src/components/` para estrutura semelhante (mesma navegação de ciclo,
   mesmo card wrapper, mesmo tooltip button, mesmo stat tile, etc.).
2. Se existir um componente que faz 80%+ do que precisas → **extrair a parte comum**
   para `src/components/common/` e adaptar ambos os usos para partilhar.
3. Só criar um componente novo se não existir nada reutilizável.

**Detecção de duplicação (obrigatório antes de fechar qualquer tarefa UI):**

- Componentes helper locais (ex: `HelpTooltip`, `InfoTooltipButton` dentro do
  mesmo ficheiro, com o mesmo propósito) → mover para `src/components/common/`.
- Blocos JSX ≥ 10 linhas repetidos em 2+ ficheiros → extrair componente.
- Props idênticas passadas por `className` condicional com a mesma lógica em 2+
  lugares → abstrair num componente ou hook.

**O critério não é "parece igual visualmente" — é "tem a mesma estrutura JSX/lógica".**
Screenshots podem enganar; ler o código é obrigatório.

## Loading & perceived performance

Stack-agnostic; em projectos EvPlanner ver `.ai/context/loading-ux.md` (precedência projecto > brain).

### Princípios

1. **Shell nunca bloqueia** — header, navegação, FAB visíveis durante fetch.
2. **Skeleton > spinner > texto** — layout-preserving (`animate-pulse`, altura ≈ conteúdo final).
3. **Initial vs background** — `isPending && !data` → skeleton; `isFetching && data` → manter UI + hint opcional.
4. **Stale-while-revalidate** — TanStack Query: `placeholderData: (prev) => prev`, `staleTime` coerente (30–60s overviews).
5. **Queries independentes** — não OR-gate loading de secções que podem renderizar separadamente.

### TanStack Query v5

| Estado | Significado | UI |
|--------|-------------|-----|
| `isPending` | Primeira carga sem cache | Skeleton por secção |
| `isFetching` | Refetch (pode ter cache) | Conteúdo anterior + indicador discreto |
| `isLoading` | Deprecated — evitar | Usar hook/util que distingue pending vs fetching |

### Acessibilidade

- Skeleton: `aria-busy="true"` + `aria-label` de loading.
- Tokens semânticos (`bg-muted`) — legível em dark/light.

### QA mínimo

- Round-trip navegação (A → B → A): conteúdo cache imediato, sem flash full-page loading.
- Mudança de filtro/ciclo: só a secção afectada entra em skeleton.
