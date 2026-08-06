# React frontend — estrutura de pastas e nomes (overflow)

> Overflow de `react-frontend.md` §4. Ler só quando se cria estrutura nova ou se
> precisa do template completo.

## Estrutura de pastas (template)

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

## Convenções de nomes

| Tipo | Padrão | Exemplo |
|------|--------|---------|
| Componentes | PascalCase | `Button.jsx` |
| Páginas | PascalCase | `DashboardPage.jsx` |
| Data / API | camelCase | `agenda.js`, `eventsApi.js` |
| Lib | camelCase | `eventFormMapper.js` |
| Hooks | use + PascalCase | `useScrollToTopOnChange.js` |
| Context | PascalCase + Context | `AuthContext.jsx` |
