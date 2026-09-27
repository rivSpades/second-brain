---
name: pen
description: >
  Workflow completo de migração .pen ↔ código para um ecrã/componente de
  qualquer projecto frontend. Invoca com /pen <nome-do-ecrã-ou-componente>
  (ex: /pen despesas, /pen dashboard, /pen navbar). Executa: detectar
  contexto do projecto → inventário de frames → consistência cross-ecrã →
  cross-check código vs .pen → actualizar .pen (Opus/modelo forte) →
  reconstruir código → QA no browser (matriz de viewports do projecto) →
  testes → commit (fluxo do próprio projecto). Genérica — não assume
  projecto, paleta, stack, nomes de componentes nem estrutura de pastas
  específicos; deriva tudo do `.pen` alvo e do AGENTS.md/CLAUDE.md do
  projecto em cada invocação.
---

# pen — Migração .pen ↔ código

> Skill **genérica** (vive em `~/brain/skills/`, não num projecto). Nada aqui é
> específico de um projecto — cada invocação deriva paths, paleta, stack,
> nomes de componentes e convenções do projecto actual. Não copiar valores de
> uma sessão anterior "de memória" para outro projecto.
>
> Par das skills `pen-create-design` (constrói um design system do zero) e
> `pen-update-design` (corrige/completa um design system já existente contra
> o baseline `checklist.design`). Esta skill assume que já existe design
> estabelecido no `.pen` alvo e trata de um **ecrã ou componente concreto**
> de cada vez — não do design system inteiro.

## O que esta skill é (e não é)

- **É** um pipeline de fidelidade: alinha um ecrã/componente de código com o
  `.pen` alvo de um projecto, no sentido único `.pen` → código.
- **Não é** dona do design system em si (foundations + biblioteca de
  componentes) — isso é `pen-create-design`/`pen-update-design`. Se faltar um
  primitivo genuíno na biblioteca do `.pen`, esta skill estende-o (mesma
  regra das duas), mas não audita o baseline de 28 itens do zero.
- **Não assume** paleta, tipografia, spacing, stack (React/Vue/Svelte/nativo)
  nem estrutura de pastas — tudo isso é lido do `.pen` e do
  `AGENTS.md`/`CLAUDE.md` do projecto no Passo 0.
- **Não redefine** o design system nesta skill — variables e componentes
  reusáveis do `.pen` mandam sempre; a skill nunca lista tamanhos/px "de
  memória" de uma sessão anterior.

## Regras base (não negociáveis)

| Regra | Detalhe |
|-------|---------|
| Zero hardcode entre projectos | Nunca reutilizar paths/paletas/nomes de componente de uma sessão anterior — derivar tudo no Passo 0 |
| `.pen` é fonte de verdade de UI | Código segue o `.pen`, nunca o inverso |
| Mutações `.pen` → modelo forte obrigatório | `Agent(model:"opus")` (alias que resolve para o Opus mais recente, hoje **Opus 5.5** — nunca fixar 5 ou anterior; ou equivalente mais capaz disponível) — nunca um modelo leve a editar `.pen`; se o projecto tiver regra própria mais específica, segui-la |
| Spacing: ler do `.pen` antes de escrever markup | `Get(nodeId, {depth:0})` em cada contentor de layout, nunca adivinhar |
| Nunca commitar sem QA no browser (ou equivalente de preview do projecto) | Confirmar visualmente antes de qualquer commit |
| Nunca remover UI silenciosamente | Ausência no `.pen` ≠ remoção — verificar a doc de produto/workflows do projecto antes de assumir |
| Auditar estados condicionais do código (Passo 1f) | Cada estado sem frame é gap obrigatório no `.pen` |
| **Consistência cross-ecrã** (Passo 0b/0c/1g/1h) | Comparar irmãos **e** masters contra `GetVariables()`/`Get(master)` no `.pen` — nunca contra memória da skill |
| **Design system = biblioteca de componentes reusáveis do `.pen`** | A skill **não** redefine o DS — actualizar/estender sempre na biblioteca existente (todos os temas que o projecto usa, ex. light+dark) |
| **Biblioteca primeiro — zero inventário paralelo** | Antes de criar reusable/secção: `Get` na biblioteca. Se já cobre → `ref`. Migração de página = **só frames de ecrã**. ❌ board/secção de inventário novo por ecrã, ❌ `Move` da biblioteca sem pedido |
| **Proibido board de componentes por ecrã** | ❌ `<Ecrã>-components`, inventário paralelo. ✅ Página completa nova se for preciso redesenhar o ecrã |
| **Divergência estrutural = repensar o `.pen`, sempre** | Tipo de gráfico, hierarquia de blocos, família de componente, ou funcionalidade do código mais rica que o `.pen` não mostra: o Passo 2 (modelo forte) **incorpora sempre** essa riqueza/estrutura no `.pen` antes do Passo 4. Não existe "perguntar ao utilizador se pode manter a divergência" — a resposta é sempre não |
| **Código só dá conteúdo, nunca visual** | Ler código para saber que estados/copy/dados/funcionalidade existem é obrigatório. Copiar a estrutura/layout visual do código para o `.pen` é proibido — o layout é sempre uma decisão de design no `.pen`, nunca uma transcrição (ver secção de contaminação abaixo) |
| **Auto-auditoria do prompt do Passo 2 antes de enviar** | Ter a frase "usa o código só para conteúdo" no prompt NÃO chega — se o resto do prompt ainda contém classes de estilo literais, cores, px, ou pares ícone/cor copiados do código, o agente vai seguir o detalhe concreto e ignorar a frase abstracta. Reler o rascunho do prompt e cortar tudo isso ANTES de disparar o Agent (checklist dedicada antes do Passo 2) |
| checklist.design verifica-se sempre, criação OU restyle | Qualquer componente tocado — novo, redesenhado, ou só reestilizado mantendo o id — passa por `~/brain/raw/checklist-design/` antes de fechar o trabalho, mesma regra de `pen-create-design`/`pen-update-design` |

---

## Guardrails anti-"AI slop" (aplicar sempre que o Passo 2 desenha algo novo, ou o Passo 4 escreve markup/copy)

> Fonte: skill pública [tasteskill.dev](https://www.tasteskill.dev/docs) / repo
> [Leonxlnx/taste-skill](https://github.com/Leonxlnx/taste-skill) — catálogo de padrões
> visuais e de copy que denunciam design gerado por IA sem curadoria. Esta skill (`/pen`)
> não define o design system (isso é `pen-create-design`/`pen-update-design`), mas
> **sempre** que o Passo 2 tem de desenhar algo novo para preencher um gap — ou o Passo 4
> escreve copy nova ao migrar para código — as mesmas regras aplicam-se, para não
> introduzir um "tell" genérico dentro de um `.pen` já curado.

**Ao preencher um gap no Passo 2 (componente ou secção nova)**
- Não introduzir uma segunda cor de destaque — usar só o accent já definido nos tokens
  do `.pen` (`GetVariables()`), nunca inventar um roxo/azul-glow "de reserva".
- Não introduzir glow externo se o `.pen` já resolve acabamento premium via borda
  interior/sombra interior — manter o mesmo mecanismo, não um halo novo.
- Respeitar o raio de canto já estabelecido (Shape Consistency Lock) e o tema já
  estabelecido (Page Theme Lock) do `.pen` — nunca "só desta vez, porque fica bem".
- Se o gap for uma secção de página inteira (não um componente): não repetir a mesma
  família de layout de uma secção vizinha (ex. não colocar duas secções seguidas de
  "3 cards iguais" ou dois zigzags consecutivos); no máximo 1 eyebrow por cada 3 secções.
- Se o gap for um hero: título máx. 2 linhas, subtítulo máx. ~20 palavras, CTA(s)
  visível(eis) sem scroll, máx. 4 elementos de texto no hero.
- Qualquer área clicável nova respeita o alvo de toque mínimo já definido nos tokens do
  projecto (tipicamente 44px), mesmo que o `.pen` antigo não o tivesse.

**Ao escrever copy no Passo 4 (migração para código)**
- Travessão (`—`/`–`) banido de todo o texto visível ao utilizador — títulos, botões,
  legendas, mensagens de estado. Reestruturar com ponto, vírgula ou dois pontos. Isto
  aplica-se independentemente de o texto vir do `.pen`, do código antigo, ou de teres de
  o escrever de novo — se encontrares um travessão em copy visível durante a migração,
  é um gap a corrigir, não preservar "porque já lá estava".
- Contraste de botão obrigatório em todos os estados migrados (default/hover/pressed/
  disabled/focus) — parte do Passo 5 (QA), não só estético.
- Uma etiqueta por intenção de CTA no ecrã inteiro — se o código antigo tiver duas
  etiquetas diferentes para a mesma acção (ex. "Contactar" num sítio e "Fale connosco"
  noutro), unificar como parte da migração, não replicar a inconsistência.

Não é preciso repetir a citação da fonte ao lançar o `Agent(model:"opus")` do Passo 2 —
só incluir o resumo accionável relevante ao gap concreto que está a ser preenchido.

---

## Passo 0 — Detectar contexto do projecto (obrigatório, sempre primeiro)

Nunca assumir. No projecto actual (cwd):

1. **Ler `AGENTS.md`/`CLAUDE.md`** (raiz e subprojectos) — procurar: qual é o
   `.pen` de design system (e se há um `.pen` legado a não tocar), onde vive
   o código de UI, qual a stack, qual o mapeamento token `.pen` → classe de
   estilo (ex. um doc tipo `design-system-tokens.md`), qual a matriz de
   QA/viewports/temas que o projecto já define, qual o comando de
   testes/lint, qual a skill/fluxo de commit local, e se existe doc de
   produto/workflows a consultar antes de remover UI (para não confundir gap
   com remoção intencional).
2. **Localizar ficheiro(s) `.pen`** no repo (`find . -iname "*.pen"`). Se
   houver mais que um, identificar qual é o alvo e qual é legado/outro —
   nunca presumir por ordem alfabética ou data; confirmar com o utilizador se
   ambíguo.
3. **Ler a doc de migração/design do projecto**, se existir (ex. um
   `.ai/context/design-system-migration.md` ou equivalente) — muitas vezes já
   documenta onde vive a biblioteca de componentes no `.pen`, o processo por
   ecrã, e componentes canónicos a reutilizar (ex. um doc de
   anti-duplicação/`component-reuse.md`).
4. **Confirmar com `AskUserQuestion` se algo continuar ambíguo** — qual `.pen`
   é o alvo, onde fica o frontend, qual a rota/URL do ecrã pedido — em vez de
   adivinhar.
5. Registar mentalmente para o resto da execução: `{ .pen alvo, .pen(s) a não
   tocar, dir do frontend, stack, mapa token→classe, matriz QA, comando de
   testes, comando de commit, doc de produto/workflows }`.

```js
get_app_state({ include_schema: false, include_canvas_design: true,
                include_scripts_and_shaders: false, include_browser: false })
// Procurar frames cujo nome contenha o nome do ecrã/componente pedido
```

---

## Design system — onde vive e como seguir

```text
Fonte de verdade do DS:  <.pen alvo, do Passo 0>
  ├─ variables                    → tokens de tipo, spacing, radius, cor
  ├─ biblioteca de componentes    → ÚNICO sítio de componentes reusáveis
  │   (todos os temas que o projecto usa, ex. light + dark)
  └─ frames de PÁGINA             → ecrãs completos (compõem UI)

A skill /pen NÃO é o design system.
❌ Copiar tabelas de tipografia/spacing para a skill ou para prompts "de memória"
❌ Inventar valores px/gap/radius no código sem Get() no .pen
❌ Criar board "<Ecrã>-components" / inventário paralelo por ecrã
❌ Nova secção/inventário de componentes — a biblioteca já existe; Get + ref
❌ Move da biblioteca sem pedido ao desenhar ecrãs
✅ GetVariables() + Get(componentId na biblioteca) → valores exactos → código
✅ Gap de primitivo genuíno → actualizar na biblioteca (todos os temas); depois a página
✅ Repensar ecrã → novo frame de PÁGINA completa; composição inline / refs ao DS
✅ Inconsistência entre ecrãs → corrigir master/token na biblioteca, depois migrar código
```

**Antes de desenhar ou migrar qualquer ecrã (obrigatório):**

```js
Print(GetVariables())
// Anotar o mapa token → valor resolvido para a sessão em curso.
// Estes valores são a régua da consistência. A skill NÃO lista sizes canónicos.
```

1. `GetVariables()` — tokens disponíveis nesta sessão.
2. Localizar o frame de inventário/biblioteca no `.pen` alvo (get_app_state /
   pesquisa de nome) e correr `Get(<id descoberto>, {depth:2})` — reutilizar,
   não reinventar. Não presumir um ID de uma sessão anterior — confirmar
   sempre nesta.
3. `Get(componentId, {depth:3+})` no master reusável — extrair propriedades de
   layout/tipo (podem ser literais **ou** referências a tokens — resolver via
   `GetVariables()`).
4. Código copia esses valores. Zero improvisação.
5. Mapear para as classes/tokens de estilo do projecto conforme o mapa lido
   no Passo 0 (ex. `design-system-tokens.md`). **Proibido** valores literais
   órfãos sem correspondência no `.pen`.

Se dois masters/variantes do mesmo papel visual divergirem no próprio `.pen`,
isso é **bug do DS no `.pen`** — unificar lá (modelo forte), não "documentar
as duas opções" na skill nem escolher no código.

---

## Consistência cross-ecrã (obrigatório)

A app **não pode parecer duas apps**. Ao tocar um ecrã, verificar os
**irmãos** que partilham métricas ou chrome (ex.: páginas gémeas, um par
receita/despesa, um par criar/editar) — e comparar contra os **mesmos**
componentes reusáveis do `.pen` + tokens de `GetVariables()`, não contra
memória. Se o projecto já documenta essas famílias/irmãos (ex. num doc de
anti-duplicação de componentes), ler essa doc no Passo 0 em vez de
reconstruir a lista do zero.

### 0b. Mapear irmãos e métricas partilhadas (obrigatório)

```text
Ecrã alvo: <nome>
Irmãos / ecrãs que partilham UI ou métrica:
  - <ecrã> — métrica: <nome> — componente: <componente/variante>
Fórmulas a validar (mesmo util / mesmo cálculo):
  - <função/módulo do código>
```

Se o ecrã tiver um irmão conhecido, esse irmão entra no Passo 1g e no QA
(pelo menos spot-check no viewport/tema base).

### 0c. Carregar régua do DS no `.pen` (obrigatório — tipografia/spacing)

**Sem isto, a "consistência" é opinião.** Antes do Passo 1:

```js
Print(GetVariables())
```

Depois `Get` nos masters do ecrã / irmãos:

| Check | Como |
|-------|------|
| Token binding | as propriedades de layout usam token **ou** literal = valor do token? |
| Mesmo papel, mesmo token | o mesmo tipo de valor em papéis equivalentes (ex. dois KPIs) resolve ao **mesmo** token |
| Sem órfãos | literais fora da escala de `GetVariables()` → gap do `.pen` (Passo 2) |
| Código | classes/valores do componente = valor **resolvido** do master (não da skill) |

```text
✅ Consistência = ecrã A, ecrã B e código batem com GetVariables + Get(master)
❌ Consistência = "lembrar o valor" sem ter corrido GetVariables nesta sessão
```

### 0d. Inventário de componentes do ecrã (obrigatório antes do Passo 1)

Listar **todos** os ficheiros de código que compõem o ecrã (página +
subcomponentes) como checklist persistente:

```text
Ecrã: <nome>
Componentes:
  [ ] <ficheiro de orquestração da página>
  [ ] <componente A>
  [ ] <componente B>
  ...
```

**Regra:** `/pen <ecrã>` só está concluído quando **cada** item desta lista
tiver passado por ler lógica do código → repensar no `.pen` (nunca só alinhar
tokens ao design que já lá está, mesmo que pareça correcto) → reconstruir o
componente. "O `.pen` já o tem" não é suficiente — pode significar só que foi
copiado do código antigo (ver sinais abaixo), não desenhado.

**Sinais de que um componente do `.pen` foi copiado do código, não
repensado:**

- Comentário no markup tipo "espelho .pen" sem mais contexto — sinal de
  alinhamento por id, não desenho.
- A estrutura do `.pen` reproduz a hierarquia que o código já tinha antes da
  migração, sem nenhuma decisão nova assinalável.
- Vários componentes do mesmo ecrã com o mesmo esqueleto genérico repetido
  sem questionar se faz sentido para cada papel.

Encontrar este padrão em qualquer item do inventário = gap do Passo 2, igual
a um gap de conteúdo em falta — mesmo que ninguém o tenha apontado.

---

## Passo 1 — Cross-check código vs .pen

### 1a. Screenshot .pen (frames existentes)

```js
get_screenshot({ nodeId: "<id>" })  // para cada frame identificado
```

### 1b. Screenshot browser (ou ferramenta de preview do projecto)

Usar a ferramenta/URL/matriz de viewports+temas que o Passo 0 identificou no
projecto (dev server, rota, viewports, forma de alternar tema). Não inventar
uma matriz genérica se o projecto já define a sua própria.

### 1c. Listar gaps

```
GAPS .pen (tem mas código não tem / está diferente):
- <item>

GAPS código (tem mas .pen não mostra):
- <item>  ← verificar doc de produto/workflows antes de assumir remoção

GAPS consistência (irmão / métrica partilhada):
- <item>

GAPS DS (.pen variables / masters):
- <item>
```

### 1d. Diff propriedade a propriedade (por componente) — obrigatório

Screenshots visuais **não são suficientes** para declarar alinhamento, e
também não bastam para decidir quais componentes existem — um screenshot
pode não destacar diferenças estruturais que só aparecem lendo os dados
reais do nó (ex.: um gráfico de barras estático vs um chart com eixos e
linha de referência pode "parecer" só cosmético mas ser um tipo de dado
completamente diferente).

**Método (ordem obrigatória — não avançar para o Passo 2/scope sem completar):**

0. **Régua DS** — Passo 0c já correu `GetVariables()`. Guardar o mapa token→valor.
1. **Enumerar primeiro, antes de qualquer diff.** Correr `Get(frameId, {depth:1})`
   (ou `depth:2` se os filhos directos forem só wrappers) e listar TODOS os
   filhos nomeados — não confiar em "o que vi no screenshot". Este output é a
   checklist: cada linha tem de aparecer na tabela de diff, ou ser
   explicitamente marcada "sem equivalente no código" / "ignorado e porquê".
2. Para cada item, obter o nodeId a partir do frame.
3. Para cada componente, `Get(nodeId, {depth:3})` (`depth` maior, ex. 4-6, se
   o componente for um `ref` para um componente reutilizável — os `refs` só
   mostram `{type:"ref", ref, ...overrides}` em depth baixo; o conteúdo real
   está no componente apontado por `ref`) e extrair: gap/padding/radius em
   contentores; tipo/peso/cor em textos; fill/stroke/dimensões em shapes. Para
   gráficos/visualizações: tipo de representação, presença de
   eixos/grid/legendas/linha de referência — linha **obrigatória** na tabela.
   ❌ estrutural = repensar sempre no `.pen` antes do Passo 4, nunca aceitar a
   divergência.
4. Ler o ficheiro de código correspondente e mapear os valores equivalentes.
5. Construir uma tabela de diff (`.pen` value resolvido vs código, coluna Match?).
6. Cobrir **todos** os itens da checklist do Passo 0d — se saltar um item,
   dizer explicitamente que foi saltado e porquê, nunca em silêncio.

### 1d-bis. Master ≠ instância — diff por FRAME, não por componente (obrigatório)

`Get(masterId)` dá a *linguagem visual de referência* — nunca o valor final.
O valor final de CADA propriedade (padding, gap, cor, tipo de gráfico) só
existe no **nó da instância real dentro do frame de página** (`ref` com
`descendants`), e essas overrides **variam por viewport/tema** — o mesmo
componente pode ter densidade diferente entre viewports (compressão
responsiva deliberada, não um acidente a normalizar). Ler só o master e
assumir que os outros frames são iguais já produziu, num projecto real,
código estruturalmente correcto mas visualmente errado em componentes onde a
instância real tinha overrides que o master não mostrava.

**Checklist obrigatória antes do Passo 4 (bloqueia o Passo 4 se incompleta) —
repetir para CADA componente reusável usado × CADA frame de página da matriz
do projecto (todos os viewports × todos os temas):**

```text
Componente: <nome>
  □ <viewport 1> <tema 1> — Get(<ref-id-desta-instância>, {depth:1}) → overrides listados
  □ <viewport 1> <tema 2> — idem
  □ ... (repetir para toda a matriz)
  Divergências entre viewports anotadas? (ex.: padding muda entre viewports) [ ]
  Se SIM: o componente recebe uma prop de densidade calculada a partir do
    layout já computado na página — nunca um breakpoint aplicado por cima de
    uma classe de token que não é uma utility de breakpoint real. Confirmar
    sempre na configuração de estilo do projecto se uma classe suporta
    mesmo variantes de breakpoint antes de lhe aplicar um prefixo.
```

Não é permitido extrapolar "já vi o master, os outros frames devem ser
iguais" — cada frame é lido individualmente. Se forem de facto idênticos em
todos os viewports, ainda assim registar isso explicitamente (não é assumido
por omissão).

**Para gráficos especificamente:** nunca aceitar "já é um line chart, deve
estar bem" como diff. Ler os nós filhos do chart node e confirmar
EXPLICITAMENTE, um a um: existe área preenchida (gradiente)? a linha tem
gradiente de cor ou é sólida? as gridlines são sólidas ou tracejadas? existe
glow/halo? Cada resposta "não sei" é um gap — não presumir que a
implementação pré-existente já cobre isto só porque é "tecnicamente" o mesmo
tipo de gráfico.

### 1d-ter. Re-verificação pós-build (obrigatório, antes de reportar "concluído")

O `.pen` é um documento colaborativo em tempo real — pode mudar enquanto
trabalhas (o próprio Pencil MCP avisa disto). Isto corta nos dois sentidos:

1. **Antes de declarar o passo de QA concluído**, repetir `Get()` nas
   instâncias reais dos frames (não confiar em notas tiradas há várias
   mensagens) e comparar contra o browser real mais uma vez. Se algo mudou
   entretanto, **não presumir qual versão é a correcta** — pode ser uma
   edição deliberada de outra pessoa a meio da sessão. Reportar a divergência
   explicitamente e perguntar antes de remover conteúdo real do produto para
   "bater" com um estado do `.pen` que pode ter sido uma edição acidental.
2. Só depois de confirmar o estado actual do `.pen` (não uma memória de
   mensagens anteriores) é que se pode declarar o cross-check fechado.

### 1e. Auditoria de componentes reutilizáveis — obrigatório

Antes de fechar o cross-check, verificar nos dois lados:

**No código — detectar duplicação:** grep por componentes locais com o mesmo
propósito, blocos JSX/markup ≥10 linhas repetidos em 2+ ficheiros. Para cada
duplicado encontrado → listar como gap: "componente X duplicado em A e B —
extrair para um componente partilhado".

**No `.pen` — detectar frames reconstruídos inline / boards ilegais:** correr
`Get(frameId, {depth:2})` nos frames do ecrã e verificar se algum nó filho
reconstrói um primitivo que já existe na biblioteca. Se sim → alinhar ao DS
(ref ou mesma estrutura+tokens), não inventar paralelos. Também falhar o
Passo 1 se existir board/frame tipo `<Ecrã>-components` — mover primitivos
para a biblioteca e apagar o board paralelo (com confirmação se já tiver
conteúdo).

**Regra:** o mesmo primitivo NÃO existe em dois sítios — nem no código, nem
no `.pen` (biblioteca vs página vs board paralelo). Variantes novas →
biblioteca, todos os temas.

**Padrões de duplicação a verificar sempre:**

- **Espelho de tema como cópia manual, não `ref`.** Se um board de tema
  alternativo (ex. dark) tiver 0 `reusable`/0 `ref` onde devia ter, é cópia
  manual byte-a-byte a rediverger silenciosamente do master principal a cada
  edição futura. Corrigir sempre substituindo por `ref` (o tema resolve as
  variables sozinho — confirmar com `resolveVariables:true`).
- **Bug de contraste entre temas.** Token PLANO usado directamente em vez de
  um token TEMÁTICO, sobre um fundo que É temático — legível num tema,
  ilegível noutro. Procurar sempre esse padrão.
- **Famílias paralelas para o mesmo conceito.** 2+ conjuntos de componentes a
  resolver o mesmo papel visual é sinal de cópia directa de 2+ componentes de
  código distintos sem consolidar — candidatos a fundir num genérico com
  eixos de variante (`descendants`), nunca 2+ masters paralelos.

### 1f. Auditoria de estados condicionais no código — obrigatório

Antes de declarar o cross-check completo, ler **todos os ficheiros de
código** do ecrã e procurar: condicionais em classes/estilo com base em
estado de negócio; variáveis de cor/estilo que mudam com estado; blocos
condicionais que mostram/escondem UI inteira; `switch`/`if` sobre estado que
resulta em markup diferente.

Para cada condicional encontrada:

| Estado no código | Trigger (variável/função) | Frame no .pen? |
|-------------|--------------------------|---------------|
| <exemplo> | <condição> | ✅/❌ |

**Regra:** se existe estado no código **sem frame correspondente no `.pen`**
→ é gap obrigatório a resolver no Passo 2. O `.pen` tem de modelar **todos**
os estados visíveis ao utilizador, não só o "happy path". Nunca remover o
estado do código para "simplificar" — o `.pen` é que tem de crescer até
cobrir todos os estados que o produto já tem.

### 1g. Auditoria de métricas/barras partilhadas — obrigatório

Para cada métrica listada no Passo 0b: abrir o ecrã irmão (`.pen` + código +
screenshot se disponível) e comparar fórmula, primitivo visual, sentido do
valor/fill, copy, e tipo/tamanho resolvido (`Get` no master de cada ecrã, não
"parece o mesmo tamanho no screenshot"). Registar na tabela de gaps se
divergir.

### 1h. Auditoria tipografia/spacing vs `GetVariables` (obrigatório)

Para o ecrã alvo **e** cada irmão do 0b: listar textos-chave (título, labels,
metadados), comparar `fontSize`/token contra o mapa 0c; para cada contentor:
gap+padding+radius vs tokens. No código: valores literais sem equivalente no
`.pen` = gap.

⚠️ **Nunca declarar "código está alinhado" com base apenas em screenshots
visuais.** O diff de propriedades (1d), a auditoria de estados (1f), métricas
(1g) e tokens DS (1h/0c) são obrigatórios antes de passar ao Passo 4.

### Divergência estrutural = repensar o `.pen`, sempre (obrigatório antes do Passo 4)

Qualquer ❌ na tabela 1d sobre **estrutura** significa que o `.pen` está
desactualizado ou incompleto — **não** que o código tem "mais features" a
preservar. A resolução é sempre a mesma: Passo 2 (modelo forte) incorpora
essa riqueza/estrutura no `.pen` antes do Passo 4. Não existe excepção
"seguir o `.pen` por defeito e perguntar depois se pode ficar assim" — o
`.pen` cresce para cobrir o que o código já faz, sempre.

| Estrutural | O que fazer |
|--------------------------------------------|----------|
| Tipo de visualização diferente (barras vs line/area, donut vs lista) | Repensar o primitivo na biblioteca para modelar o tipo real de dados/gráfico |
| Hierarquia de blocos diferente do frame | Redesenhar o frame de página para reflectir a hierarquia real |
| Família de componente diferente (ex. hero dedicado vs bloco ad hoc) | Escolher/estender a família certa na biblioteca — nunca manter um bloco ad hoc |
| Primitivo de KPI/barra diferente do papel | Unificar na biblioteca qual é o primitivo correcto para esse papel |
| Funcionalidade do código mais rica (eixos, categorias extra, tooltip, estados) | Modelar essa riqueza no `.pen` — nunca simplificar/descartar para bater com um desenho mais pobre |

```text
✅ .pen tem barras, código tem line chart → repensar no .pen se deve ser
   line/area (modelo forte decide, informado pelos dados reais), depois código segue
✅ código tem 6 categorias, .pen mostra 2 → Passo 2 modela as 6 categorias reais
❌ "Preservar funcionalidade mais rica, só ajustar tokens do wrapper" → não
❌ "Placeholder / já tem mais / parece só cosmético" → continuar a análise
❌ Perguntar ao utilizador se pode manter a divergência — a resposta é sempre não
❌ Migrar spacing/tokens e deixar a estrutura desalinhada
```

Nota técnica (contexto, **não** desculpa): o Pencil desenha mal points de
linha — por isso muitos frames usam barras por defeito. Isso não dispensa o
Passo 2 de desenhar o gráfico certo se os dados reais pedirem outra coisa —
usar o melhor mecanismo disponível no Pencil para representar o tipo de dado
real, nunca aceitar um tipo errado só porque é mais fácil de desenhar.

---

## Antes do Passo 2 — auto-auditoria obrigatória do prompt (hard gate)

**Isto já falhou tantas vezes que é agora um passo explícito, não uma nota de
rodapé.** Padrão do incidente, sempre igual: o orquestrador lê os ficheiros de
código para tirar o inventário de conteúdo (correcto, obrigatório — Passo
0d/1f), mas depois escreve o prompt do Passo 2 transcrevendo o que viu no
markup/CSS em vez de só o comportamento. Ter uma frase tipo "usa o código só
para conteúdo" no mesmo prompt **não protege contra isto** — o agente segue o
detalhe concreto, não o aviso abstracto.

**Antes de chamar `Agent(...)` no Passo 2, reler o rascunho do prompt inteiro
e procurar por qualquer um destes sinais — se aparecer UM que seja, reescrever
essa frase antes de enviar:**

| Sinal proibido no prompt | Exemplo do que NÃO escrever | Reescreve como (conteúdo, não visual) |
|---|---|---|
| Classe de estilo literal | ex. `bg-sage-100 text-sage-700` copiado do código | "usa um chip/nota de aviso — decide a cor/tom a partir da biblioteca" |
| Cor por nome ou hex | `amber-800`, `#EF4444` | "cor semântica de aviso/perigo — a tua escolha no DS" |
| Medida em px/rem | `34×34`, `text-[46px]`, `h-14` | omitir — o tamanho é decisão de layout |
| Par ícone+cor por categoria copiado do código | "conta=sage, cripto=âmbar, ..." | "cada tipo tem um ícone identificador — iconografia à tua escolha" |
| Arranjo/proporção de grelha copiado do CSS | `grid-cols-[1.55fr_1fr]`, "col-esq 566px" | "agrupa em colunas seguindo o padrão já usado em ecrãs equivalentes — a proporção é tua" |
| Descrição "X ao lado de Y do tamanho Z" | qualquer frase que permita redesenhar o componente sem abrir a biblioteca | reescrever como lista de estados/condições/dados, sem arranjo espacial |

**Teste rápido antes de enviar:** se alguém conseguisse redesenhar o
componente pixel-a-pixel só a partir do teu prompt, sem nunca abrir `Get()`
na biblioteca — é transcrição, não brief de conteúdo. Reescreve.

Isto aplica-se ao prompt inteiro, não só à frase de aviso — nomes de tokens
do `.pen` **são** permitidos (são o vocabulário do `.pen`, não do código);
IDs de componentes da biblioteca a reutilizar **são** permitidos (são pontos
de partida de desenho, não transcrição); classes de estilo, hex, px e pares
ícone/cor tirados do código **não são** permitidos em nenhuma circunstância.

---

## Repensar um componente já existente (não gap novo) — mecanismo de contaminação (ler antes de qualquer "redesenha X")

Confirmado empiricamente (sessão de auditoria de design system, 2026-08-11,
~17 componentes): pedir a um agente "lê o código só para conteúdo, decide o
desenho, só depois abre o `.pen`" **não chega**, mesmo escrito explicitamente,
mesmo repetido numa segunda tentativa com o aviso reforçado. Seis agentes em
paralelo, todos com essa instrução, produziram seis re-skins do que já
existia — de forma independente. Um auto-diagnosticou-se correctamente:

> "Li o código-fonte primeiro e trouxe de lá mais do que dados... a sequência
> [eyebrow→número→sublinha→barra→escala→rodapé] é exactamente a invenção que
> o dono rejeitou... Abri o `.pen` antigo e deixei-o conduzir... Calibrei com
> screenshots e converti isso em 'seguir o padrão da casa'."

**Porquê acontece sempre, não é falta de esforço do agente:**

1. Markup de UI não separa conteúdo de composição. "Este componente mostra
   label, depois valor, depois gráfico" já é uma descrição de layout
   disfarçada de lista de dados — não há forma de "ler só os dados" sem
   absorver também a ordem/agrupamento em que aparecem.
2. Um único agente, numa única janela de contexto, não esquece o que já viu.
   Depois de o código (com a composição) e o `.pen` antigo estarem os dois no
   mesmo contexto que a decisão de desenho, o viés de edição incremental
   ("isto já está quase bem, ajusto") domina — o mesmo mecanismo que faz um
   LLM preferir um diff pequeno a uma reescrita, mesmo instruído ao contrário.
3. Calibrar contra componentes "bons" já existentes no mesmo ficheiro vira
   facilmente desculpa para convergir na mesma estrutura "por coerência com a
   casa".

**O que resolve isto de facto — escolher UM, nunca só reforçar o prompt:**

- **(a) Separação real de contexto.** Um agente só extrai conteúdo do código
  para texto simples, sem nunca abrir o `.pen`. Um segundo agente recebe *só*
  esse texto + tokens (`GetVariables()`) e desenha o conceito **sem nunca
  abrir o `.pen`** — nem "só para ver as instâncias". Um terceiro agente (sem
  autoridade de desenho) implementa o conceito já fechado e liga instâncias
  reais.
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

**Quando isto se aplica:** só quando o pedido é "repensa/redesenha X, não
gosto do que está" — não para preencher um gap novo (checklist ⚠️/❌) nem
para deduplicar/fundir masters preservando o visual (esse trabalho é
mecânico, sem risco de contaminação criativa).

---

## Passo 2 — Actualizar .pen (se há gaps)

**Obrigatório: lançar `Agent(model:"opus")`** (ou o modelo forte que o Passo 0
identificou como preferência do projecto).

```
Agent({
  model: "opus",
  description: "Actualizar .pen — <nome-do-ecrã>",
  prompt: """
    Tens o .pen aberto em Pencil MCP: <path exacto do .pen alvo, Passo 0>
    (NUNCA o .pen legado, se existir: <path>)

    Frames do ecrã <nome>: <ids identificados no Passo 0/1, matriz completa
    de viewports × temas do projecto>

    Gaps identificados (código tem, .pen não mostra / inconsistência irmão):
      <lista>

    Tokens: correr Print(GetVariables()) nesta sessão — usar os tokens
            existentes. NÃO inventar valores na skill.
    Biblioteca de componentes (IDs desta sessão): <ids> — percorrer antes
      de qualquer Insert de UI
    Componentes/família relevantes: só os que existem na biblioteca; IDs via
      Get (NÃO reaproveitar IDs de uma sessão/ficheiro anterior)

    Regras:
    - Usa o código SÓ para saberes que passos/estados/copy/dados existem — o
      LAYOUT é sempre uma decisão tua a partir da família de componentes já
      estabelecida na biblioteca (Get('<id-biblioteca>', {depth:2})); NUNCA
      transcrevas a estrutura visual do componente de código existente
    - Se o código tiver funcionalidade mais rica que o que vês no .pen (mais
      categorias, mais eixos, mais estados) — incorpora essa riqueza no
      novo design, nunca a simplifiques para bater com algo mais pobre
    - Tema alternativo (ex. dark) via Copy + override de tema — tokens
      resolvem automaticamente
    - Spacing/tipo: GetVariables + Get(nodeId) antes de Insert/Update;
      preferir binding a tokens em vez de literais órfãos
    - Matriz completa de viewports × temas do projecto no final
    - Não inventar fluxos — só o que a doc de produto/workflows do projecto
      / código já têm
    - OBRIGATÓRIO DS: componentes só na biblioteca (todos os temas).
      Actualizar/estender aí. PROIBIDO criar board "<Ecrã>-components",
      inventário paralelo. Página completa nova = OK. Composição de página =
      dentro do frame da página.
    - Se faltar primitivo: checklist ~/brain/raw/checklist-design/… e criar
      na biblioteca — nunca num board de ecrã
    - Páginas gémeas / ecrãs irmãos: mesma casca que os frames/masters no
      .pen já definem
    - Tipografia/spacing/radius: só GetVariables + Get(component) — proibido
      ad hoc

    Após concluir: get_screenshot de todos os frames e confirmar sem clipping.
  """
})
```

Se o `.pen` já está correcto e completo → saltar este passo.

---

## Passo 3 — Extrair spacing/tipo do .pen (obrigatório antes de escrever markup)

```js
Print(GetVariables())           // régua de tokens
Get('<nodeId>', { depth: 0 })   // gap, padding, radius, layout
Get('<textId>', { depth: 0 })   // fontSize (token ou literal) → resolver
```

Mapear o valor resolvido → **token/classe do projecto** (lido no Passo 0, ex.
um doc `design-system-tokens.md`), não literais inventados.

```text
❌ text-[32px] font-bold  (mesmo que "bata" com o valor)
✅ classe/token do projecto que já mapeia para esse valor
❌ Copiar px da skill — GetVariables manda; se a config do projecto divergir
   do .pen, actualizar a config
```

---

## Passo 4 — Migrar código

**Regra obrigatória: apagar e reconstruir, nunca "actualizar".**

Mesmo que o código pareça visualmente próximo do `.pen`, **não edites
componentes existentes tentando aproximá-los**. Essa abordagem acumula
divergências silenciosas (spacing ligeiramente errado, classes legacy,
lógica antiga entrosada). O processo correcto é:

1. **Identificar os ficheiros a substituir** para este ecrã.
2. **Ler o conteúdo actual** de cada ficheiro (para preservar lógica de
   dados, hooks, mutations, event handlers — tudo o que não é visual).
3. **Apagar o markup/estilo existente** de cada componente e reconstruí-lo do
   zero a partir dos frames do `.pen`, frame a frame, componente a
   componente.
4. **Preservar apenas** o que não é estrutura visual: data fetching e
   handlers de estado; lógica condicional de negócio (empty/loading/error);
   event handlers; copy (usar sempre a fonte de i18n do projecto, se
   existir).
5. **Reescrever o markup** com a hierarquia de elementos, spacing,
   border-radius e cores exactamente como o `.pen` define — valores do Passo
   3, nunca adivinhar.
6. **Reutilizar primitivos partilhados** já existentes no projecto (Passo 0)
   — não reinventar um bloco que já tem componente comum.
7. **Alinhar fórmulas** aos utils/módulos partilhados do projecto, não
   duplicar cálculo por página.

**Nunca:**
- Declarar "já está alinhado" e saltar a reconstrução — mesmo que pareça igual
- Adivinhar spacing/tipo sem `Get()` no `.pen` (e sem `GetVariables()` para tokens)
- Valores de estilo que não batem com o master/frame no `.pen`
- Remover lógica de negócio (data fetching, handlers) durante a reconstrução
- Aceitar divergência entre variantes/irmãos sem primeiro unificar no `.pen`
- Definir ou "corrigir" o design system na skill — o DS só muda no `.pen`
- Avançar Passo 4 sem primeiro ter repensado no `.pen` qualquer ❌ estrutural
  (tipo de gráfico, hierarquia, família) — nunca aceitar a divergência
- Justificar no código "`.pen` é placeholder" / "mantemos X por UX" para
  evitar a reconstrução

---

## Passo 5 — QA no browser (matriz do projecto)

Usar a matriz de viewports × temas que o Passo 0 identificou como padrão do
projecto (ex.: mobile/tablet/desktop × light/dark). Para cada combinação:
screenshot, e verificar:

- [ ] Sem overflow/clipping
- [ ] Spacing/tipo visualmente iguais ao `.pen` **e** iguais aos tokens 0c
- [ ] Tema alternativo: cores correctas
- [ ] Conteúdo completo (sem elementos desaparecidos)

**Consistência (se Passo 0b listou irmão):**
- [ ] Spot-check do irmão num viewport base — mesma métrica + mesmo valor
- [ ] Mesmo token resolvido no bloco partilhado (`Get` vs código) — Passo 1h
- [ ] Chrome/hero não "parece outra app"

Se o projecto documenta uma forma específica de alternar tema (ex. um toggle
na app, não só emulação do DevTools), usar essa forma — ver Passo 0.

---

## Passo 6 — Testes

Correr o comando de testes/lint que o `AGENTS.md`/config do projecto define
(Passo 0) — nunca assumir um comando genérico sem confirmar. Falhas
pré-existentes não relacionadas: documentar, não bloquear. Falhas novas:
corrigir antes de continuar. Se o ecrã tiver uma métrica/barra com regra de
negócio fixa (ex. "fill = X, não Y"), incluir pelo menos um assert dedicado a
essa regra.

---

## Passo 7 — Commit + push

Usar o fluxo de commit próprio do projecto (skill local, se existir) — não
inventar um formato de mensagem novo se o projecto já tiver convenção
própria. Não commitar sem pedido explícito do utilizador.

---

## Gotchas técnicos do Pencil MCP

Comportamento da ferramenta, não específico de nenhum projecto:

| Sintoma | Causa | Como evitar |
|---|---|---|
| `Replace` lança `TypeError: Cannot read properties of undefined` | `Replace` não aceita um `ref` como alvo nem como nó de substituição quando está dentro de um master `reusable` | Usar `Insert` (novo nó) + `Delete` (nó antigo) em vez de `Replace`, nesses casos |
| `Update(id,{descendants:{...}})` não limpa overrides antigos | `Update` faz **merge** do objecto `descendants`, nunca substitui | Para "limpar" um override, `Delete` a instância e recriar, ou apagar chaves específicas manualmente |
| Override deixa de resolver depois de ires lá mexer outra vez | Um override do tipo *replacement* (troca de subtree inteira via `descendants`) não é endereçável pela chave original depois de aplicado — a árvore já mudou | Editar os nós reais da substituição pelos **ids próprios**, não pela chave original do `descendants` |
| Conteúdo real de instâncias desaparece depois de um `Delete` | Apagar um nó **poda silenciosamente** os `descendants` de todas as instâncias `ref` que o referenciam | **Sempre**: capturar (`Get` + gravar em ficheiro/scratchpad) os `descendants` de TODAS as instâncias reais ANTES de qualquer `Delete`/`Replace` no nó alvo. Nunca inverter a ordem, mesmo quando "não deve haver referências" |
| Erro de schema em `alignItems` | `"baseline"` e `"stretch"` não são valores suportados | Usar `"start"`/`"center"`/`"end"` |
| Screenshot de um nó em tema alternativo sai com cores do tema base | O tema vive no frame de **board** ancestral, não se aplica a um screenshot de subnó isolado | Aplicar o token de fundo temático ao próprio nó antes do screenshot (reverter depois), ou verificar com `Get(id,{depth:N,resolveVariables:true})` em vez de confiar só no visual |
| `execute({filePath:"..."})` parece ignorar o parâmetro | O MCP do Pencil lê sempre o documento activo no editor — `filePath` não muda isso | Não usar para comparar contra um snapshot do git — não serve para diff histórico |
| Aviso `"fill_container… not inside a flexbox layout"` em nós que sabes estarem correctos | Falso positivo do validador quando o nó tem `enabled:false`, ou artefacto residual de um `Replace` recente a referir o id antigo já apagado | Confirmar com leitura fresca (`Get` + `ctx.problems`) antes de assumir que é um bug real |
| `width`/`height` com referência a variável (`width:"$tap-target-min"`) é silenciosamente ignorado, sem erro — o nó colapsa para `fit_content` | `width`/`height` numéricos **não aceitam** `$token`, ao contrário de cor/padding/gap/cornerRadius/stroke, que aceitam normalmente | Chamar `GetVariables()`, ler o valor resolvido, e usar o número literal directamente em `width`/`height`. Confirmar com `Get`+`ctx.bounds` que a dimensão real bate com o esperado, sobretudo em alvos de toque (`tap-target-min`) |
| Corriges `width`/`height` no componente reutilizável (master), mas instâncias (`ref`) já criadas ficam com a geometria antiga/colapsada | `ref` não recalcula geometria retroactivamente a partir do master depois de a instância já existir | Aplicar override explícito de `width`/`height` em cada instância já criada (`Update(instanceId,{width:...,height:...})`), ou — melhor — definir o tamanho numérico correcto no momento da criação do master, antes de instanciar |
| `Copy(swatchId, parent, {descendants:{"<nome-do-filho>":{...}}})` de um nó **não-reusable** (a maioria dos swatches `ds/...` de showcase) não aplica o override — falha em silêncio, o filho fica com o conteúdo original | O mapa `descendants` por chave de **nome** só é resolvido nesse formato para instâncias `ref` de um componente `reusable:true`; num `Copy` normal essa chave não é reconhecida | Depois do `Copy`, ler o id devolvido do nó copiado, localizar o filho real (`Get(copiedId,{depth:2})` ou visitor à procura do nome) e aplicar `Update(childId,{...})` directamente pelo **id**, nunca por nome, quando a origem não é `reusable:true` |
| `effect: {type:"shadow", shadowType:"inner", ...}` é gravado silenciosamente como `"outer"` — sem erro, sem aviso. Grave se usado para simular "fio de luz interior"/glass: o resultado é um HALO EXTERIOR colorido, exactamente o "AI slop" que as guardrails anti-slop proíbem | O Pencil não suporta inner shadow real neste momento; a propriedade é aceite no schema mas convertida ao gravar | **Nunca usar `effect` do tipo `shadow` para acabamento "interior".** Usar `stroke` com `strokeAlignment:"inner"` em vez disso — para um "fio de luz" (glass/highlight): `stroke: {type:"gradient", gradientType:"linear", rotation:180, size:{height:1}, colors:[{color:"$border-highlight",position:0},{color:"$border-subtle",position:1}]}, strokeWidth:"$border-width-hairline", strokeAlignment:"inner"` (receita validada em produção). Para uma sombra de profundidade lisa (ex. estado "pressed"): `stroke:"$token-de-sombra"` sólido, mesmo `strokeAlignment:"inner"`. **Se o Passo 2 desta skill desenhar algo novo com acabamento "interior", auditar com `Get`+visitor a contar `effect.shadowType==="outer"` cuja `color` referencie tokens de highlight/inset — qualquer contagem >0 é este bug** |
| Instância `ref` continua a renderizar o estado ANTIGO do master mesmo depois de confirmares por `Get` directo que o master já tem a propriedade nova | Refs criados antes da edição do master, com `descendants` ausente/`undefined` (nunca tocados), não recalculam automaticamente — `Update(instanceId,{descendants:{}})` (objecto vazio) também **não** força o recálculo | `Update(instanceId,{descendants:{<childId>:{<propriedade real>:...}}})` com um valor a sério (mesmo que redundante, igual ao do master) força a instância a repropagar |
| Largura fixa em px que resolve o problema num master isolado (showcase) volta a quebrar em instâncias de página reais | Instâncias reais em layouts de coluna dividida têm MENOS largura disponível do que o showcase — o schema não suporta `%`/`vh`/`calc` (só px literal) | Antes de fixar qualquer largura, listar TODAS as instâncias reais e o `ctx.bounds.width` do CONTENTOR real de cada uma — se variar, precisas de overrides de largura por instância/grupo, não um valor único no master |

---

## Onde ficam os ficheiros/paths concretos

Esta skill nunca lista paths de projecto, nomes de componentes canónicos ou
comandos concretos numa tabela fixa — isso pertence ao contexto de cada
projecto (`AGENTS.md`/`CLAUDE.md`/`.ai/context/`), lido sempre no Passo 0.
Se um projecto ainda não documenta isso (`.pen` alvo, mapa de tokens, matriz
de QA, comandos), sinalizar o gap ao utilizador em vez de inventar — e sugerir
registá-lo na doc do projecto para a próxima invocação não repetir a
descoberta.
