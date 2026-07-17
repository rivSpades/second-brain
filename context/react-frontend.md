# React frontend — padrão cross-tool

> Carregado via `~/brain/LOADER.md` §7 quando o workspace é React (qualquer LLM com ponteiro para o brain).  
> **Não substitui o projecto** — cada repo tem o seu `Context.md` com stack, produto e caminhos concretos.

## Activação (stack compatível)

Aplica **só** quando o workspace for frontend React:

1. `package.json` na raiz (ou na pasta frontend do monorepo) tem `react` em `dependencies` ou `devDependencies`.
2. Se a stack divergir do padrão (ex.: Next.js, CRA, Remix), **adapta** ao `Context.md` e `package.json` — não forces Vite/Tailwind se o projecto não os usar.

**Precedência:** regras do projecto (`Context.md`, `AGENTS.md`, `.cursor/rules/`) > este ficheiro.

---

## 1. Arranque obrigatório

1. **Ler `Context.md` na raiz do projeto** — sempre o primeiro passo.
2. Seguir a ordem de documentação que o `Context.md` indica (ex.: `docs/ARCHITECTURE.md`, `docs/MAPPING.md`, `docs/DESIGN.md`).
3. Se `Context.md` não existir: inspeccionar `package.json`, `src/` e `docs/`; criar `Context.md` com propósito, stack e mapa de docs; depois continuar.

O `Context.md` é a **fonte de verdade do projeto**. Estas regras são o **padrão genérico** — versões, domínios e design vêm do projeto.

---

## 2. Papel e âmbito

- **Papel:** developer frontend (fullstack quando o prompt pedir).
- **Âmbito:** executar **apenas** o pedido actual. Não arrastar tarefas de prompts anteriores.

---

## 3. Stack de referência (ajustar ao `Context.md`)

Padrão para novos projetos React mobile-first:

| Área | Tecnologia |
|------|------------|
| Build | **Vite** |
| UI | **React** (versão no `package.json` do projeto) |
| Routing | **React Router** — `createBrowserRouter` em `src/router.jsx` |
| CSS | **Tailwind CSS 3.x** + `postcss.config.js` + `autoprefixer` |
| Animação | **Framer Motion** |
| Ícones | **@phosphor-icons/react** |
| Env | prefixo **`VITE_`** + `import.meta.env` |
| Qualidade | ESLint + `npm run build` |

Scripts habituais: `npm run dev`, `npm run build`, `npm run lint`.

---

## 4. Estrutura de pastas (template)

```
project/
├── Context.md                 # Entrada — produto, stack, mapa de docs
├── README.md                  # Setup, rotas, QA manual
├── .env.example
├── docs/
│   ├── ARCHITECTURE.md
│   ├── MAPPING.md             # data ↔ lib ↔ UI por domínio
│   ├── DESIGN.md              # Design system — ler antes de UI
│   ├── README.md              # Índice de APIs / integrações
│   └── {DOMAIN}_API.md        # Um ficheiro por domínio de API
├── .cursor/rules/
│   ├── init.mdc               # alwaysApply — aponta para Context.md
│   ├── architecture.mdc       # globs: src/**/*
│   └── design.mdc             # globs: src/**/*
├── public/
└── src/
    ├── main.jsx
    ├── router.jsx
    ├── index.css
    ├── styles/                # tokens.css, temas
    ├── constants/
    ├── data/
    │   ├── api.js             # HTTP único
    │   ├── {domain}.js        # Façade — a UI importa daqui
    │   ├── {domain}Api.js     # Endpoints + cache
    │   └── mock/              # Fallback controlado por env
    ├── lib/
    │   ├── {domain}ApiMapper.js
    │   ├── {domain}FormMapper.js
    │   ├── {domain}Utils.js
    │   └── validation.js
    ├── components/
    │   ├── ui/                # Design system
    │   ├── layout/
    │   └── {domain}/
    ├── pages/{domain}/
    ├── hooks/
    └── store/                 # Context global (auth, tema, etc.)
```

### Convenções de nomes

| Tipo | Padrão | Exemplo |
|------|--------|---------|
| Componentes | PascalCase | `Button.jsx` |
| Páginas | PascalCase | `DashboardPage.jsx` |
| Data / API | camelCase | `agenda.js`, `eventsApi.js` |
| Lib | camelCase | `eventFormMapper.js` |
| Hooks | use + PascalCase | `useScrollToTopOnChange.js` |
| Context | PascalCase + Context | `AuthContext.jsx` |

---

## 5. Camada de dados (3 níveis)

```
Componente / Página / Wizard
        ↓ import
data/{domain}.js          ← API estável para a app
        ↓
data/{domain}Api.js       ← paths HTTP, cache
        ↓
lib/*Mapper.js
        ↓
data/api.js               ← apiFetch, auth headers, erros
```

| Camada | Ficheiro | Responsabilidade |
|--------|----------|------------------|
| HTTP | `api.js` | fetch, CSRF, Bearer, normalização de erros |
| API | `*Api.js` | URLs, cache, chamadas brutas |
| Façade | `{domain}.js` | Funções de negócio, mappers, fallback mock |
| API → UI | `*ApiMapper.js` | listas, detalhe, summaries |
| UI → API | `*FormMapper.js` | payloads POST/PATCH, catálogos |
| Apresentação | `*Utils.js` | formatação, labels — sem HTTP |
| Validação | `validation.js` | `validate*Step`, `validate*Form` |

Façades devolvem objectos previsíveis, por exemplo: `{ success, data?, message?, fieldErrors? }`.

**A UI não chama HTTP directamente** — importa sempre de `data/{domain}.js`.

Antes de integrar um endpoint novo: documentar em `docs/{DOMAIN}_API.md` e actualizar `docs/MAPPING.md`.

---

## 6. Routing e autenticação

- Router central em `src/router.jsx`.
- `ProtectedRoute` / `PublicRoute` para rotas públicas vs autenticadas.
- Layout autenticado (shell, tab bar, header) num componente de layout dedicado.
- Páginas finas em `pages/` — lógica em `components/{domain}/`.
- Loaders/actions do React Router: usar quando simplificam o fluxo; não são obrigatórios em todos os ecrãs.
- Auth e base URL: seguir o que `Context.md` e `docs/ARCHITECTURE.md` do projeto definem.

---

## 7. Estado global

React Context **só** para estado verdadeiramente global:

- autenticação, tema, notificações, perfil activo, chrome da app (título, acções do header)

Estado de página ou de wizard fica no componente ou num hook local.

Para lógica complexa em context: preferir `useReducer` a múltiplos `useState` independentes.

---

## 8. Formulários e wizards

Padrão multi-passo recomendado:

1. Passos com ids estáveis (`categoria`, `tipo`, `identificação`, …).
2. Seleção visual com componentes reutilizáveis do design system (`SelectableOptionTile`, `SelectableOptionCard`, etc.).
3. Header com voltar/fechar + acções de passo no rodapé (Continuar / Guardar).
4. Validação por passo antes de avançar; validação completa no submit.
5. Ecrã de sucesso com acções opcionais (ex.: configurar alertas).

Campos obrigatórios do payload: conforme `docs/{DOMAIN}_API.md`.

---

## 9. Design system e UI

1. Ler **`docs/DESIGN.md`** do projeto antes de criar ou alterar UI.
2. Reutilizar **`src/components/ui/`** antes de estilos ad hoc.
3. **Mobile-first:** estilos base; `md:` tablet; `lg:` desktop.
4. Tokens semânticos (cores, superfícies, texto) — evitar hex solto em componentes.
5. Animações com **Framer Motion**; alvos de toque ≥ 44×44px.
6. `aria-label` nos controlos só com ícone.

---

## 10. Ambiente e mocks

- Variáveis em `.env.example` com prefixo `VITE_`.
- Mocks em `src/data/mock/` activados por flags explícitas no env (ex.: `VITE_MOCK_{DOMAIN}=true`).
- Façade: API real primeiro; mock como fallback documentado no README do domínio.
- Nunca activar mocks silenciosamente em produção.

---

## 11. Fluxo de trabalho

```bash
npm install
cp .env.example .env    # ajustar VITE_API_URL e restantes
npm run dev
```

Após alterações significativas:

```bash
npm run lint
npm run build
```

QA manual por módulo: documentar no `README.md` do projeto.

---

## 12. Checklist — novo domínio ou feature

1. Ler `Context.md` e `docs/{DOMAIN}_API.md`.
2. `data/{domain}Api.js` + `data/{domain}.js`.
3. `lib/{domain}ApiMapper.js` (+ `FormMapper`, `Utils` se aplicável).
4. Entradas em `lib/validation.js` se houver wizard.
5. `components/{domain}/` + `pages/{domain}/`.
6. Rotas em `router.jsx`.
7. Actualizar `docs/MAPPING.md`.
8. UI conforme `docs/DESIGN.md`.

---

## 13. Princípios de código

- **Minimizar scope** — diff focado no pedido.
- **Reutilizar** convenções e componentes existentes no repo.
- **Separar camadas** — UI, façades, HTTP, mappers.
- **Documentar** APIs e mapa de ficheiros ao adicionar domínios.
- Comentários só onde a lógica de negócio não é óbvia.

---

## 14. Resumo arquitectural

1. **`Context.md` primeiro** — depois o mapa de docs do próprio projeto.
2. **Vite + React + Tailwind + React Router** como base.
3. **Data layer em 3 níveis** com mappers em `lib/`.
4. **Páginas finas**, componentes de domínio ricos.
5. **Estado global mínimo** em `store/`.
6. **Design system** em `components/ui/` + `docs/DESIGN.md`.
7. **Documentação autocontida** — `Context.md`, `docs/`, `.cursor/rules/`.

---

## 15. Loading & perceived performance

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
