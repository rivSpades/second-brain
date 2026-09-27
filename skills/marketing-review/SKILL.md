---
name: marketing-review
description: >
  Audita SEO/marketing digital (SEO clássico + GEO/visibilidade em pesquisa por IA) de
  qualquer projecto com presença pública (site, landing, loja) contra a biblioteca local
  `~/brain/raw/checklist-seo/` (18 ficheiros, 7 categorias: technical, ai-search-geo,
  on-page, keywords, off-page, content-marketing, social-media), nunca contra o blog do
  Semrush ao vivo. Selecciona só as categorias que se aplicam às necessidades reais do
  projecto (nem todo projecto tem loja/presença local/blog/redes sociais), audita item a
  item contra o código e (quando existir) documentação de acesso a GA4/Search
  Console/Google Business Profile do próprio projecto, e produz um relatório de estado +
  um plano faseado e priorizado. É revisão e plano, não execução — não edita código,
  copy nem documentação de negócio sozinha. Invoca com /marketing-review (sem
  argumentos) — deriva tudo do AGENTS.md/CLAUDE.md e do código do projecto actual. Usa
  quando o utilizador disser "marketing review", "auditoria de SEO", "revê o SEO deste
  site", "o que falta em marketing/SEO", ou quiser um plano de acção de SEO/GEO para um
  projecto.
---

# marketing-review — Auditoria de SEO/marketing digital e plano de acção

> Skill **genérica** (vive em `~/brain/skills/`, não num projecto), no mesmo espírito das
> skills `pen-*`: nada aqui é específico de um projecto — cada invocação deriva domínio,
> stack, público e maturidade de marketing do projecto actual. Não copiar itens, URLs ou
> conclusões de uma sessão anterior "de memória" para outro projecto.

## O que esta skill é (e não é)

- **É** uma auditoria read-only + plano. Produz um relatório de estado por categoria e um
  plano de acção faseado e priorizado.
- **Não implementa nada sozinha.** Corrigir um item do plano (ex. adicionar `FAQPage`
  schema, criar um ficheiro de mapa de keywords) é um pedido explícito à parte, depois de
  o utilizador ver o plano — mesmo que a correcção seja trivial.
- **Não assume** que o projecto é um site de marketing tradicional. Cobre desde uma
  landing page simples a uma loja online ou um produto com marketing site próprio. Se o
  projecto for uma aplicação puramente interna/privada sem nenhuma presença pública,
  esta skill diz isso e pára — não inventa itens para preencher um relatório.
- **Não assume** idioma, stack, CMS, estrutura de conteúdo, nem que o utilizador tem
  acesso a contas Google/GBP — tudo isso deriva-se do projecto no Passo 0, e a ausência de
  acesso fica registada como tal, nunca como gap.
- Fonte da checklist = **só** `~/brain/raw/checklist-seo/` — nunca aceder ao blog do
  Semrush ao vivo a partir desta skill (mesma regra que `pen-update-design` tem para
  `checklist.design`).

## Passo 0 — Detectar contexto do projecto (obrigatório, sempre primeiro)

Nunca assumir. No projecto actual (cwd):

1. **Ler `AGENTS.md`/`CLAUDE.md`** (raiz e subprojectos) — stack, domínio(s)/URL(s) de
   produção, onde vive o código de páginas públicas, se existe documentação própria de
   acesso a Google Analytics/Search Console/Google Business Profile (padrão tipo
   `.ai/context/google-access.md` + `analytics-rules.md`, mas o nome varia por projecto —
   procurar pelo conteúdo, não por um nome fixo), e se o projecto tem convenção de
   `docs/plans/` para guardar planos versionados.
2. **Confirmar que há presença pública.** Se o projecto for uma app interna/admin/SaaS
   sem nenhuma página pública indexável, dizer isso explicitamente e parar aqui — nada a
   rever.
3. **Localizar as peças técnicas do site**: ficheiro de robots (`robots.ts`/`robots.txt`
   estático), sitemap, função(ões)/componentes de metadata (title, description,
   canonical, hreflang, keywords), componentes de JSON-LD/schema markup, conteúdo de blog
   (se existir), frontmatter de páginas/serviços/produtos com campos tipo `seo:`.
4. **Confirmar com o utilizador se ambíguo** — vários domínios no mesmo repo, stack não
   óbvia, mais que um "site" — em vez de adivinhar.

## Passo 0.5 — Que categorias se aplicam (necessidades do projecto, não a lista toda)

A biblioteca tem 7 categorias (`technical`, `ai-search-geo`, `on-page`, `keywords`,
`off-page`, `content-marketing`, `social-media`). Decidir por inferência do Passo 0 —
**nunca perguntar ao utilizador por rotina**, só se genuinamente ambíguo (ex.: não é claro
se há intenção de blog):

| Categoria | Aplica-se quando… | Registar como não aplicável quando… |
|---|---|---|
| `technical` | Há um site público (quase sempre) | Nunca — é sempre a base |
| `ai-search-geo` | Há qualquer conteúdo público indexável | Site 100% autenticado/privado |
| `on-page` | Há páginas de conteúdo/produto/serviço | — |
| `keywords` | Há páginas a competir por intenção de pesquisa | Só uma app interna sem páginas de marketing |
| `off-page` — link building | Há intenção de crescer autoridade/backlinks | Fase muito inicial, nada publicado ainda (registar como "cedo demais", não gap) |
| `off-page` — local SEO/GBP | Negócio com presença física ou área de serviço geográfica | Produto 100% remoto/global sem componente local |
| `content-marketing` | Existe ou está planeado blog/conteúdo regular | Sem blog nem intenção de ter |
| `social-media` | Existem ou estão planeados canais sociais activos | Sem presença social nem intenção |

Cada categoria não aplicável entra no relatório final com a razão — nunca omitida em
silêncio.

## Passo 1 — Ler a biblioteca local (só as categorias aplicáveis)

```
Read ~/brain/raw/checklist-seo/<categoria>/*.md
```

Nunca aceder ao blog do Semrush ao vivo a partir desta skill — só a biblioteca local. Se
suspeitar que está desactualizada (o utilizador menciona algo recente que não está lá),
sinalizar como possível refresh a fazer depois (nova sessão de research dirigida, fora do
âmbito desta skill) e continuar com o que a biblioteca tem agora.

## Passo 2 — Auditoria item a item

Para cada item de cada ficheiro aplicável, verificar contra o projecto real:

- **Código**: grep/leitura directa (robots, sitemap, schema, funções de metadata,
  frontmatter de conteúdo).
- **Site ao vivo**, se o domínio de produção for conhecido e público — confirmar
  `robots.txt`/`sitemap.xml` reais (via `WebFetch`/`WebSearch`), não só o código-fonte:
  código e produção podem divergir (deploy antigo, env errado, etc.).
- **Documentação própria do projecto** sobre GA4/Search Console/GBP, se existir (ler, não
  assumir acesso a contas onde não há doc a prová-lo).

Classificar cada item: `[feito]` / `[parcial]` / `[por fazer]` / `[não aplicável:
<razão>]` — sempre com evidência (`ficheiro:linha`, URL verificado, ou "não verificável
sem acesso a X").

## Passo 3 — Relatório de estado

Uma tabela por categoria aplicável, item a item, com o resultado do Passo 2. Gerar de
raiz para o projecto actual a partir da auditoria — nunca copiar conteúdo ou conclusões
doutro projecto (cada projecto tem o seu próprio nível de maturidade).

## Passo 4 — Plano faseado e priorizado

Converter só os itens `[por fazer]`/`[parcial]` num plano por fases (pular fases sem
itens, nunca inventar trabalho para as preencher):

1. **Fase 1 — base técnica**: crawlability (robots.txt/sitemap correctos, incluindo bots
   de IA), dados estruturados básicos, GSC/GA4 configurados — pré-requisito do resto; sem
   isto, o resto tem efeito limitado.
2. **Fase 2 — conteúdo e keywords**: mapa de keywords por página, metadata por página,
   FAQ/schema citável, conteúdo estruturado para ser extraído por IA.
3. **Fase 3 — autoridade e alcance**: off-page (link building, local SEO/GBP se
   aplicável), content marketing e social media (só as categorias marcadas aplicáveis no
   Passo 0.5).
4. **Fase 4 — monitorização**: tracking de rankings, tracking de citações/menções em IA,
   cadência de revisão (ex. trimestral).

Cada item do plano inclui: acção concreta, porquê (link ao ficheiro da checklist em
`~/brain/raw/checklist-seo/<categoria>/<ficheiro>.md`), e se depende de algo que só o
utilizador pode fazer (contas Google/GBP, credenciais, decisões de copy/negócio) —
marcar isso explicitamente; esta skill nunca assume posse dessas contas nem as cria em
nome do utilizador.

## Passo 5 — Apresentar, nunca implementar sozinha

Mostrar relatório + plano ao utilizador. Se o projecto tiver convenção própria de
`docs/plans/` (Passo 0), oferecer gravar o plano lá (ex. `docs/plans/marketing-review-
<data>.md`) — só depois de confirmação; não deixar o plano a viver só no chat se o
projecto já tiver esse hábito para outros planos. Implementar qualquer item do plano é um
pedido à parte, feito depois desta entrega.

## Reexecução

Sem estado próprio entre corridas — cada invocação audita de novo do zero (não há modo
diff-and-patch como nas skills `pen-*`, porque não há um artefacto único tipo `.pen` a
comparar). Reexecutar periodicamente é o esperado; comparar o relatório novo com o plano
anterior (se o utilizador o tiver guardado em `docs/plans/`) fica ao critério de quem lê,
não é automatizado por esta skill.
