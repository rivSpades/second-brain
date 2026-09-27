---
name: pen-create-design
description: >
  Constrói um design system completo num ficheiro `.pen` de um projecto
  (qualquer frontend), no estilo de um designer/estética à escolha, cobrindo
  sempre a totalidade de foundations + components de
  checklist.design/design-system (28 itens), verificados contra uma biblioteca
  local (~/brain/raw/checklist-design/), nunca contra o site ao vivo. Genérica
  — não assume projecto, paleta, stack nem estrutura de pastas específicos;
  deriva tudo do `.pen` e do contexto do projecto (AGENTS.md/CLAUDE.md) em cada
  invocação. Invoca com /pen-create-design [nome_designer] (ex:
  /pen-create-design "Gleb Kuznetsov", ou sem argumento para continuar o estilo
  já estabelecido no `.pen` alvo). Workflow: detectar projecto + `.pen` alvo →
  resolver designer/estilo → auditar os 28 itens obrigatórios → ler a
  biblioteca local de checklists → cross-check por item → construir/estender no
  `.pen` (Opus) → reconstruir código preservando lógica → QA → testes → commit
  (só se pedido).
---

# pen-create-design — Construir um design system completo num `.pen`

> Skill **genérica** (vive em `~/brain/skills/`, não num projecto). Nada aqui é
> específico de um projecto — cada invocação deriva paths, paleta, stack e
> convenções do projecto actual. Não copiar valores de uma sessão anterior
> "de memória" para outro projecto.

## O que esta skill é (e não é)

- **É** um workflow de construção: (a) detecta se já existe um design system no
  `.pen` alvo de um projecto, (b) garante que os 4 foundations + 24 components
  listados em `checklist.design/design-system` existem nesse `.pen` e cumprem
  todos os itens da checklist correspondente, no estilo do designer/estética
  resolvido no Passo 0.5 — **independentemente do que o código do projecto já
  implementa hoje**. Este baseline (28 itens) é sempre obrigatório, mesmo numa
  primeira execução num `.pen` vazio.
- **Não é** dona do `.pen` legado do projecto. Se o projecto já tiver um `.pen`
  "oficial" diferente do alvo (ex.: uma skill própria de migração `.pen ↔
  código`, tipo uma skill `/pen` local), esta skill não o substitui nem redefine
  qual é "oficial" — só constrói/actualiza o `.pen` alvo explicitamente
  identificado no Passo 0. Formalizar o `.pen` alvo como fonte de verdade de um
  ecrã inteiro é decisão do utilizador, não assumir.
- **Não expande obrigatoriamente** para as categorias Website / Web App /
  Mobile App / Flows de checklist.design — essas são tratadas à parte (Passo 9,
  oportunista, nunca bloqueante desta skill).
- **Não assume** paleta de cores, tipografia, spacing, stack (React/Vue/…) nem
  estrutura de pastas — tudo isso é lido do `.pen` e do `AGENTS.md`/`CLAUDE.md`
  do projecto em cada execução (Passo 0).

## Regras base (não negociáveis)

| Regra | Detalhe |
|-------|---------|
| Zero hardcode entre projectos | Nunca reutilizar paths/paletas/nomes de componentes de uma sessão anterior — derivar tudo no Passo 0 |
| Fonte do tratamento visual | O `.pen` alvo identificado no Passo 0 — ler sempre dele (`GetVariables()`, `Get(nodeId)`), nunca inventar estilo de memória |
| `.pen` legado do projecto (se existir) intocável nesta skill | Se um gap exigir mudar esse ficheiro, é fora de âmbito — avisar o utilizador, não mexer |
| Mutações a QUALQUER `.pen` → modelo forte obrigatório | Lançar `Agent(model:"opus")` (alias que resolve para o Opus mais recente, hoje **Opus 5.5** — nunca fixar 5 ou anterior; ou o equivalente mais capaz disponível) — nunca um modelo leve a editar `.pen`; se o projecto tiver regra própria mais específica (ex. "Opus 5.5 ou Kimi k3"), segui-la |
| id + anotação já vêm no `.pen` | Componentes seguem tipicamente `ds/<categoria>/<componente>--<variante>` com uma anotação de texto ao lado com a string de classes literal (Tailwind ou equivalente do projecto) — ler essa anotação em vez de adivinhar; se o `.pen` do projecto usar outra convenção, seguir a dele; se o `.pen` estiver vazio, adoptar esta convenção por omissão |
| Baseline obrigatório = checklist.design/design-system | Os 4 foundations + 24 components (28 itens, lista fixa no Passo 1) — sempre, mesmo que o código actual não implemente nada disso ainda |
| Fonte da checklist = só a biblioteca local | `~/brain/raw/checklist-design/` — **nunca** aceder a checklist.design ao vivo a partir desta skill (ver Passo 2) |
| Categorias fora do baseline são oportunistas | Website / Web App / Mobile / Flows só entram via Passo 9, e já estão cacheadas — não expandem o âmbito obrigatório da corrida |
| Designer por omissão | Se `<nome_designer>` for omitido, continuar o estilo já estabelecido no `.pen` alvo (Passo 0.5) — só perguntar ao utilizador se o `.pen` estiver genuinamente vazio/sem estilo |
| Apagar e reconstruir, nunca "aproximar" editando | Ver Passo 5 |
| Nunca commitar sem QA | Confirmar visualmente (browser ou o método de preview do projecto) antes de qualquer commit |
| Nunca remover UI/lógica silenciosamente | Preservar hooks, data fetching, handlers, estados condicionais — só a camada visual muda |
| Não commitar sem pedido explícito | Usar o fluxo de commit do próprio projecto (skill local, se existir) só quando o utilizador pedir |

---

## Guardrails anti-"AI slop" (aplicar sempre, em qualquer Passo 4/5, qualquer projecto)

> Fonte: skill pública [tasteskill.dev](https://www.tasteskill.dev/docs) / repo
> [Leonxlnx/taste-skill](https://github.com/Leonxlnx/taste-skill) — catálogo de padrões
> visuais e de copy que denunciam design gerado por IA sem curadoria. Aplica-se a
> **qualquer** projecto/estilo construído por esta skill, não é opcional nem depende do
> designer escolhido no Passo 0.5 — o estilo determina a estética, estas regras
> determinam se a execução dessa estética é intencional ou genérica.

**Cor**
- Máximo 1 accent color por `.pen`. Variações do mesmo accent (tom/opacidade) sim; uma
  segunda cor de destaque "para variar", não.
- Evitar roxo/violeta ou glow azul-roxo como accent por defeito ("Lila Rule") — é o tell
  visual mais comum de design gerado por IA sem curadoria. Só usar se o designer/estilo
  escolhido ou a marca do projecto o exigir explicitamente.
- Sem preto puro (`#000000`) nem branco puro (`#FFFFFF`) nos tokens base — usar
  off-black/off-white.
- Sem glow externo por defeito. Acabamento premium/"glass": borda interior subtil +
  sombra interior, não halo colorido à volta do elemento.
- Color Consistency Lock: o accent escolhido usa-se em toda a página, nunca troca de
  secção para secção.

**Forma e tema**
- Shape Consistency Lock: um único sistema de raio de canto por `.pen` (documentar a
  regra se houver excepção deliberada, ex. "botões pill, cards 16px, inputs 8px").
- Page Theme Lock: um tema por página (não inverter light/dark a meio do scroll), salvo
  pedido explícito de "theme switch" como efeito deliberado.

**Composição** (relevante ao desenhar ecrãs inteiros, não só componentes — ver Passo 9)
- Sem grelha de 3 cards iguais como padrão por defeito para secções de
  serviços/funcionalidades — preferir assimetria, bento com nº de células = nº de itens,
  ou zigzag limitado a no máximo 2 secções seguidas.
- Eyebrow restraint: no máximo 1 eyebrow (label pequena em maiúsculas acima de um título
  de secção) por cada 3 secções da página — nunca uma em cada secção.
- Não repetir a mesma família de layout de secção mais que uma vez na mesma página.
- Sem "split-header" (título grande + parágrafo pequeno a flutuar ao lado) por defeito —
  uma secção, uma mensagem.

**Hero**
- Título máximo 2 linhas no desktop; subtítulo máximo ~20 palavras/3-4 linhas; CTA(s)
  visível(eis) sem scroll.
- Máximo 4 elementos de texto no hero (eyebrow opcional + título + subtítulo + CTAs) —
  tagline extra, tira-teima de clientes, preço ou lista de features descem para secções
  próprias.
- Sem "scroll cues" decorativos (setas, "scroll ↓", rato animado).

**Botões e formulários**
- Contraste de botão obrigatório em todos os estados (default/hover/pressed/disabled/
  focus) — nunca texto e fundo do mesmo tom.
- Texto do botão nunca quebra linha; uma etiqueta por intenção de CTA em toda a página
  (não misturar "Contactar"/"Fale connosco"/"Vamos conversar" para a mesma acção).
- Placeholder nunca substitui label; label sempre visível.
- Qualquer área clicável cumpre o alvo de toque mínimo definido nos tokens do projecto
  (tipicamente 44px) mesmo que o visual pareça mais pequeno.

**Testemunhos** (quando existirem no âmbito do `.pen`)
- Máximo 3 linhas de citação; atribuição sempre com nome + função (+ empresa se
  aplicável), nunca só um nome.

**Copy visível ao utilizador** (quando esta skill também gera ou revê texto de UI)
- Travessão (`—`/`–`) banido de todo o texto visível — títulos, botões, legendas, texto
  de estado. Reestruturar com ponto, vírgula ou dois pontos. Não se aplica a documentação
  interna do projecto (specs, PRDs, notas).
- Sem verbos de enchimento genéricos ("revolucionar", "elevar o potencial") nem números
  inventados com precisão falsa (`99%`, `4.2x`) sem fonte real.

Ao lançar `Agent(model:"opus")` no Passo 4, incluir um resumo accionável destas regras no
prompt (não é preciso repetir a citação da fonte) — são parte do que "construir
correctamente" significa nesta skill, ao mesmo nível que o baseline dos 28 itens.

---

## Passo 0 — Detectar contexto do projecto (obrigatório, sempre primeiro)

Nunca assumir. No projecto actual (cwd):

1. **Ler `AGENTS.md`/`CLAUDE.md`** (raiz e subprojectos) — procurar: qual é o
   `.pen` de design system, onde vive o código de UI, qual a stack (React/Vue/
   Svelte/nativo), qual o comando de testes, qual a skill/fluxo de commit local
   (ex.: `/commit-push`), e se existe já uma skill própria de migração `.pen`.
2. **Localizar ficheiro(s) `.pen`** no repo (`find . -iname "*.pen"`). Se houver
   mais que um, identificar qual é o alvo (nome sugestivo, ou perguntar ao
   utilizador se ambíguo) e qual é legado/outro — nunca presumir por ordem
   alfabética ou data.
3. **Confirmar com o utilizador se ambíguo** — em vez de adivinhar qual `.pen` é
   o alvo, ou qual pasta é o frontend, quando o projecto não deixa isso óbvio.
4. Registar mentalmente para o resto da execução: `{ .pen alvo, .pen(s) a não
   tocar, dir do frontend, stack, comando de testes, comando de commit }`.

## Passo 0.5 — Resolver designer/estilo (obrigatório, antes de qualquer auditoria)

```js
get_app_state({ include_schema: false, include_canvas_design: true,
                include_scripts_and_shaders: false, include_browser: false })
// filePath: <.pen alvo detectado no Passo 0>
```

1. **Se `<nome_designer>` foi passado como argumento**: usar esse nome. Se o
   `.pen` alvo já tiver um estilo estabelecido diferente (frame de foundations
   com outra estética, anotações com outro nome/paleta), **não sobrescrever
   silenciosamente** — reportar o conflito ao utilizador e perguntar como
   reconciliar (novo tema/variante dentro do mesmo `.pen` vs. substituir o
   estilo existente).
2. **Se `<nome_designer>` foi omitido**: procurar sinais de estilo já
   estabelecido no `.pen` alvo — frame de foundations, anotações de texto junto
   a componentes, variables de cor/glow/gradiente já definidas, o próprio nome
   do ficheiro (ex. um `.pen` chamado `*-gleb-*` sugere Gleb Kuznetsov). Se
   encontrado → continuar esse estilo sem perguntar.
3. **Se o `.pen` estiver genuinamente vazio/genérico** (sem frame de
   foundations, sem anotações, sem variables de marca) e nenhum argumento foi
   dado → usar `AskUserQuestion` para pedir o nome do designer/estética antes de
   avançar. Não inventar uma estética por omissão.

## Passo 1 — Auditar os 28 itens obrigatórios (`.pen` + código)

Tabela fixa — estes são os 4 foundations + 24 components de
`checklist.design/design-system` (URL de cada um:
`https://www.checklist.design/design-system/<slug>`):

**Foundations**: Typography (`typography`), Spacing / Grid
(`spacing-and-grid`), Color System (`color-system`), Tokens (`tokens`).

**Components**: Drawer (`drawer`), Date Picker (`date-picker`), Accordion
(`accordion`), Skeleton (`skeleton`), Carousel (`carousel`), Banner (`banner`),
Slider (`slider`), Toast (`toast`), Tabs (`tabs`), Checkbox (`checkbox`), Radio
(`radio`), Searchbar (`searchbar`), Tooltip (`tooltip`), Modal (`modal`),
Loading (`loading`), Toggle (`toggle`), Input Field (`input-field`), Icon
(`icon`), Table (`table`), Card (`card`), Button (`button`), Badge (`badge`),
Avatar (`avatar`), Dropdown Menu (`dropdown-menu`).

Para cada um dos 28: verificar no `.pen` alvo (`get_app_state`/`Get` no frame de
inventário, se existir) e no código do projecto (grep no dir do frontend
detectado no Passo 0) se já existe. Produzir uma tabela de 28 linhas:

| Item | Slug | Estado `.pen` | Estado código |
|------|------|----------------|----------------|
| Button | `button` | ✅/⚠️/❌ | ✅/⚠️/❌ |
| … | … | … | … |

`✅` = existe e parece completo; `⚠️` = existe parcialmente; `❌` = não existe.

## Passo 2 — Ler a biblioteca local (nunca o site ao vivo)

Para cada um dos 28 itens (pelo menos os `⚠️`/`❌`; para os `✅` também vale a
pena ler para confirmar que "existe" == "cumpre os itens"):

```
Read ~/brain/raw/checklist-design/design-system/<slug>.md
```

Este ficheiro já contém: título, descrição, todos os itens da checklist,
o texto completo da aba "Documentation" (o critério mais accionável), e uma
lista "Related". **Esta skill nunca acede a `checklist.design` ao vivo** — a
biblioteca em `~/brain/raw/checklist-design/` foi extraída uma vez (todas as
110 páginas do site, não só estas 28) e é a única fonte. Se um ficheiro
esperado não existir (não deveria acontecer para estes 28), sinalizar ao
utilizador que a biblioteca parece incompleta — não tentar `navigate_page` ao
site a partir desta skill.

## Passo 3 — Cross-check por item de checklist

Para cada um dos 28 itens, uma tabela com uma linha por item da checklist lida
no Passo 2 (não só propriedades visuais — a unidade aqui é o critério do
checklist):

| Item checklist | Cumprido no `.pen`? | Cumprido no código? | Evidência |
|-----------------|----------------------|------------------------|-----------|
| … | ✅/⚠️/❌ | ✅/⚠️/❌ | `Get(nodeId)` / ficheiro:linha |

Cobrir **todos** os itens de cada checklist lida, não só os óbvios. Se saltar
algum, dizer explicitamente que foi saltado e porquê.

## Repensar um componente já existente (não gap novo) — mecanismo de contaminação

Aplica-se sempre que o pedido é "este componente está mal, repensa-o" — não a
preencher um gap `❌` novo nem a fundir/deduplicar masters preservando o
visual (isso é mecânico, sem risco de contaminação criativa).

Confirmado empiricamente (sessão EvPlanner, 2026-08-11, ~17 componentes):
dizer a um agente "lê o código só para conteúdo, decide o desenho, só depois
abre o `.pen`" **não chega**, mesmo escrito explicitamente, mesmo reforçado
numa segunda tentativa. Seis agentes em paralelo, todos com essa instrução,
produziram seis re-skins do que já existia — de forma independente e sem se
verem uns aos outros. Um auto-diagnosticou-se correctamente:

> "Li o código-fonte primeiro e trouxe de lá mais do que dados... a sequência
> [eyebrow→número→sublinha→barra→escala→rodapé] é exactamente a invenção que
> o dono rejeitou... Abri o `.pen` antigo e deixei-o conduzir... Calibrei com
> screenshots e converti isso em 'seguir o padrão da casa'."

**Porquê acontece sempre, não é falta de esforço do agente:**

1. Markup de UI (JSX/HTML/Vue template/…) não separa conteúdo de composição.
   "Este componente mostra label, depois valor, depois gráfico" já é uma
   descrição de layout disfarçada de lista de dados — não há forma de "ler só
   os dados" sem absorver também a ordem/agrupamento em que aparecem.
2. Um único agente, numa única janela de contexto, não esquece o que já viu.
   Depois de o código-fonte (com a composição) e o `.pen` antigo estarem os
   dois no mesmo contexto que a decisão de desenho, o viés de edição
   incremental ("isto já está quase bem, ajusto") domina — o mesmo mecanismo
   que faz um LLM preferir um diff pequeno a uma reescrita, mesmo instruído
   ao contrário.
3. Calibrar contra componentes "bons" já existentes no mesmo `.pen` (para
   nível de acabamento) vira facilmente desculpa para convergir na mesma
   estrutura "por coerência com a casa".

**O que resolve isto de facto — escolher UM, nunca só reforçar o prompt:**

- **(a) Separação real de contexto.** Um agente só extrai conteúdo do código
  actual para texto simples, sem nunca abrir o `.pen`. Um segundo agente
  recebe *só* esse texto + tokens (`GetVariables()`) e desenha o conceito
  **sem nunca abrir o `.pen`** — nem "só para ver as instâncias". Um terceiro
  agente (sem autoridade de desenho) implementa o conceito já fechado e liga
  instâncias reais.
- **(b) Conceito decidido fora de um agente com acesso ao `.pen`, revisto
  pelo utilizador antes de qualquer implementação.** Mais fiável quando o
  componente é visível/importante: o orquestrador (não um `Agent` com acesso
  ao `.pen`) desenha o conceito em código real — um protótipo HTML/CSS
  usando os tokens exactos do `.pen` (`GetVariables()`) publicado como
  `Artifact` — e só dispara um `Agent(model:"opus")` de **implementação
  apenas** (sem autoridade de desenho, só executa a especificação já
  fechada) depois de aprovação explícita do utilizador.

Instruções de texto tipo "não copies a estrutura antiga" dentro do MESMO
prompt que depois manda o agente "abrir o `.pen` para ver as instâncias"
**não bastam** — a mitigação tem de ser estrutural (contexto separado ou
revisão humana antes da implementação), nunca só mais uma frase de aviso.

## Passo 4 — Construir/estender no `.pen` alvo (`Agent(model:"opus")`)

```
Agent({
  model: "opus",
  description: "Construir/estender <.pen alvo> — <foundation/component>",
  prompt: """
    .pen: <path exacto do .pen alvo detectado no Passo 0>
    (NUNCA o .pen legado: <path, se existir>)
    Designer/estilo: <resolvido no Passo 0.5>
    Componente/foundation: <nome> (checklist.design/design-system/<slug>)

    Itens da checklist a cumprir (lidos de
    ~/brain/raw/checklist-design/design-system/<slug>.md — Checklist +
    Documentation):
      <lista de itens com a descrição de cada um>

    Gaps identificados no Passo 3 (o que falta/diverge):
      <lista>

    Seguir a convenção de id + anotação já usada no ficheiro (verificar um
    componente vizinho antes de inventar convenção nova) — se for a primeira
    execução (sem inventário ainda), criar um frame "Design System ·
    Inventário de Componentes" e usar `ds/<categoria>/<componente>--<variante>`.
    Tokens base já definidos no .pen (GetVariables()) — reutilizar, não
    duplicar. Cobrir os mesmos temas (light/dark ou o que o ficheiro já usa).
    Registar o componente novo/actualizado no inventário.
  """
})
```

Saltar este passo para os itens já `✅` no Passo 3.

---

## Passo 5 — Reconstruir a implementação (apagar e reconstruir, nunca "aproximar")

Não editar o componente existente tentando empurrá-lo visualmente para perto do
`.pen` — isso acumula divergências silenciosas. Por componente:

1. Ler o ficheiro actual por completo — preservar tudo o que não é visual
   (hooks, data fetching, handlers, lógica de estado, chaves de i18n/copy).
2. Apagar o markup/classes visuais existentes.
3. Reconstruir a partir da anotação do componente no `.pen` (Passo 1/4) —
   classes/valores exactos, incluindo variante de tema quando divergir.
4. Se existir um primitivo reutilizável no projecto (ex. `Button`, `Card` num
   dir de componentes de UI partilhados) — actualizar esse primitivo em vez de
   duplicar estilo inline, para manter um único ponto de verdade.
5. Não remover estados condicionais (loading/error/empty) — só re-estilizar.

---

## Passo 6 — QA

Se o projecto for web com browser disponível: percorrer os viewports/temas
relevantes (mobile/tablet/desktop × light/dark, ou o que o projecto já tratar
como matriz padrão — verificar `AGENTS.md`/skills locais de QA antes de inventar
uma). Confirmar: sem overflow/clipping, efeitos visuais (glass/blur/gradiente,
se aplicável ao estilo) renderizam (atenção a purga de CSS em classes usadas
apenas em runtime), cores correctas no tema escuro, conteúdo/estados completos.

Se o projecto não for web, ou não houver ferramenta de preview disponível,
dizer isso explicitamente em vez de simular QA.

## Passo 7 — Testes

Correr o comando de testes/lint que o `AGENTS.md`/`package.json` (ou
equivalente) do projecto define — nunca assumir `npm test` genérico sem
confirmar. Falhas pré-existentes não relacionadas: documentar, não bloquear.
Falhas novas: corrigir antes de continuar.

## Passo 8 — Commit (só se o utilizador pedir)

Usar o fluxo de commit próprio do projecto (skill local tipo `/commit-push`, se
existir) — não inventar um formato de mensagem novo se o projecto já tiver
convenção própria.

## Gotchas técnicos do Pencil MCP (aprendidos em sessão EvPlanner, 2026-08-11)

Aplicam-se a qualquer projecto — são comportamento da ferramenta Pencil, não
específicos do `.pen` alvo.

| Sintoma | Causa | Como evitar |
|---|---|---|
| `Replace` lança `TypeError: Cannot read properties of undefined` | `Replace` não aceita um `ref` como alvo nem como nó de substituição quando está dentro de um master `reusable` | Usar `Insert` (novo nó) + `Delete` (nó antigo) em vez de `Replace`, nesses casos |
| `Update(id,{descendants:{...}})` não limpa overrides antigos | `Update` faz **merge** do objecto `descendants`, nunca substitui | Para "limpar" um override, `Delete` a instância e recriar, ou apagar chaves específicas manualmente |
| Override deixa de resolver depois de ires lá mexer outra vez | Um override do tipo *replacement* (troca de subtree inteira via `descendants`) não é endereçável pela chave original depois de aplicado — a árvore já mudou | Editar os nós reais da substituição pelos **ids próprios**, não pela chave original do `descendants` |
| Conteúdo real de instâncias desaparece depois de um `Delete` | Apagar um nó **poda silenciosamente** os `descendants` de todas as instâncias `ref` que o referenciam | **Sempre**: capturar (`Get` + gravar em ficheiro) os `descendants` de TODAS as instâncias reais ANTES de qualquer `Delete`/`Replace` no nó alvo. Nunca inverter a ordem, mesmo quando "não deve haver referências" |
| Erro de schema em `alignItems` | `"baseline"` e `"stretch"` não são valores suportados | Usar `"start"`/`"center"`/`"end"` |
| Screenshot de um nó em tema dark sai com cores de tema light | O tema (`theme:{mode:"dark"}`) vive no frame de **board** ancestral, não se aplica a um screenshot de subnó isolado | Aplicar o token de fundo temático ao próprio nó antes do screenshot (reverter depois), ou verificar com `Get(id,{depth:N,resolveVariables:true})` em vez de confiar só no visual |
| `execute({filePath:"..."})` parece ignorar o parâmetro | O MCP do Pencil lê sempre o documento activo no editor — `filePath` não muda isso | Não usar para comparar contra um snapshot do git — não serve para diff histórico |
| Aviso `"fill_container… not inside a flexbox layout"` em nós que sabes estarem correctos | Falso positivo do validador quando o nó tem `enabled:false`, ou artefacto residual de um `Replace` recente a referir o id antigo já apagado | Confirmar com leitura fresca (`Get` + `ctx.problems`) antes de assumir que é um bug real |
| `width`/`height` com referência a variável (`width:"$tap-target-min"`) é silenciosamente ignorado, sem erro — o nó colapsa para `fit_content` | `width`/`height` numéricos **não aceitam** `$token`, ao contrário de cor/padding/gap/cornerRadius/stroke, que aceitam normalmente | Chamar `GetVariables()`, ler o valor resolvido, e usar o número literal directamente em `width`/`height`. Confirmar com `Get`+`ctx.bounds` que a dimensão real bate com o esperado, sobretudo em alvos de toque (`tap-target-min`) |
| Corriges `width`/`height` no componente reutilizável (master), mas instâncias (`ref`) já criadas ficam com a geometria antiga/colapsada | `ref` não recalcula geometria retroactivamente a partir do master depois de a instância já existir | Aplicar override explícito de `width`/`height` em cada instância já criada (`Update(instanceId,{width:...,height:...})`), ou — melhor — definir o tamanho numérico correcto no momento da criação do master, antes de instanciar |
| `effect: {type:"shadow", shadowType:"inner", ...}` é gravado silenciosamente como `"outer"` — sem erro, sem aviso. Grave se usado para simular "fio de luz interior"/glass: o resultado é um HALO EXTERIOR colorido, exactamente o "AI slop" que as guardrails anti-slop proíbem | O Pencil não suporta inner shadow real neste momento; a propriedade é aceite no schema mas convertida ao gravar | **Nunca usar `effect` do tipo `shadow` para acabamento "interior".** Usar `stroke` com `strokeAlignment:"inner"` em vez disso — para um "fio de luz" (glass/highlight): `stroke: {type:"gradient", gradientType:"linear", rotation:180, size:{height:1}, colors:[{color:"$border-highlight",position:0},{color:"$border-subtle",position:1}]}, strokeWidth:"$border-width-hairline", strokeAlignment:"inner"` (receita validada em produção). Para uma sombra de profundidade lisa (ex. estado "pressed"): `stroke:"$token-de-sombra"` sólido, mesmo `strokeAlignment:"inner"`. **Depois de qualquer construção que use "inner" em qualquer forma, auditar com uma query `Get`+visitor a contar `effect.shadowType==="outer"` cuja `color` referencie tokens de highlight/inset — qualquer contagem >0 é este bug, não uma escolha de design** |

## Passo 9 — Cobertura oportunista fora do baseline (não bloqueante)

Se o Passo 1 (auditoria de código) revelar padrões que mapeiam a categorias não
obrigatórias de checklist.design (Website / Web App / Mobile / Flows — ex.
haver um fluxo de onboarding, um ecrã de billing, um paywall), ler o ficheiro
correspondente em `~/brain/raw/checklist-design/<categoria>/<slug>.md` (já
cacheado — nenhum fetch novo é necessário) e registar como uma lista de "gaps
opcionais" para uma invocação futura ou pedido explícito do utilizador. Nunca
expandir o âmbito obrigatório da corrida actual para os cobrir.
