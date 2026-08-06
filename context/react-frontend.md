# React frontend — padrão cross-tool

> Carregado via `~/brain/LOADER.md` §7 quando o workspace é React (qualquer LLM com ponteiro para o brain).  
> **Não substitui o projecto** — cada repo tem o seu `Context.md` com stack, produto e caminhos concretos.

Overflow (lazy-load, só quando relevante):

| Ficheiro | Quando ler |
|----------|------------|
| `react-frontend-structure.md` | Criar estrutura nova — template de pastas + convenções de nomes |
| `react-frontend-detail.md` | Formulários/wizards, setup mobile `index.html`, anti-duplicação de componentes, loading/UX |

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

## 4. Estrutura de pastas

Template completo e convenções de nomes: `react-frontend-structure.md`.
Pontos fixos: `src/data/` (camada de dados), `src/lib/` (mappers/utils),
`src/components/{ui,layout,{domain}}`, `src/pages/`, `src/store/`.

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

Padrão multi-passo e validação por passo: `react-frontend-detail.md` § Formulários.

## 9. Design system e UI

1. Ler **`docs/DESIGN.md`** do projeto antes de criar ou alterar UI.
2. Reutilizar **`src/components/ui/`** antes de estilos ad hoc.
3. **Mobile-first:** estilos base; `md:` tablet; `lg:` desktop.
4. Tokens semânticos (cores, superfícies, texto) — evitar hex solto em componentes.
5. Animações com **Framer Motion**; alvos de toque ≥ 44×44px.
6. `aria-label` nos controlos só com ícone.
7. **Nunca duplicar** o mesmo componente visual em 2+ lugares — regra absoluta e detecção: `react-frontend-detail.md` § Reutilização.
8. Setup mobile (`index.html` viewport + listeners iOS): `react-frontend-detail.md` § Setup mobile.

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
Loading/UX percebida (skeletons, TanStack Query states): `react-frontend-detail.md` § Loading.

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

## 14. Resumo arquitectural

1. **`Context.md` primeiro** — depois o mapa de docs do próprio projeto.
2. **Vite + React + Tailwind + React Router** como base.
3. **Data layer em 3 níveis** com mappers em `lib/`.
4. **Páginas finas**, componentes de domínio ricos.
5. **Estado global mínimo** em `store/`.
6. **Design system** em `components/ui/` + `docs/DESIGN.md`.
7. **Documentação autocontida** — `Context.md`, `docs/`, `.cursor/rules/`.
