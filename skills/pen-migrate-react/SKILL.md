---
name: pen-migrate-react
description: >
  Migração completa e obrigatória de UM ecrã específico do `.pen` para
  código — sem excepções, sem "só os fixes seguros", sem dívida técnica por
  omissão. Invoca com /pen-migrate-react <ecrã> (ex: /pen-migrate-react
  dashboard). Ordem fixa e não negociável: (1) auditar TODAS as
  primitivas/componentes reusáveis do `.pen` usadas no ecrã contra o que já
  existe no código — instalar ou actualizar o que faltar ou divergir; (2)
  eliminar componentes órfãos que essa instalação/actualização tornou
  obsoletos; (3) só depois migrar o ecrã componente a componente, frame a
  frame, tal e qual como está no `.pen` — nenhum item do inventário do ecrã
  pode ficar por tratar nem virar "tech debt" só por dar trabalho. Genérica
  — deriva projecto/stack/`.pen` alvo do AGENTS.md/CLAUDE.md a cada
  invocação. Nasceu de um incidente real (dashboard `p4l_next`, 2026-08-21):
  `/pen` convergiu cedo em 3 fixes "seguros" e escreveu o resto no
  tech-debt-tracker em vez de o fazer — proibido repetir esse padrão aqui.
---

# pen-migrate-react — migração completa de um ecrã, sem atalhos

> Sibling da skill `/pen` (mesma família, mesmo Pencil MCP, mesmas regras de
> design system). A diferença não é técnica — é de **disciplina de âmbito**:
> `/pen` pode convergir num subconjunto de correcções quando isso faz
> sentido; esta skill existe especificamente para quando o pedido é "migra
> este ecrã todo" e **não há subconjunto aceitável**. Se tiveres dúvida sobre
> qual skill usar, usa esta.

## O incidente que originou esta skill (ler antes de tudo)

Pedido: "vamos passar os ecrãs do dashboard que estão no `.pen` para o
react". Execução real com `/pen`: leitura extensa e correcta de todos os
componentes do ecrã (3 tabs, ~20 ficheiros), mas a decisão de implementação
convergiu cedo em **3** correcções de baixo risco (Tabs, DoughnutChart,
AssetListItem) e **duas divergências estruturais reais** (gráfico "Finanças
do mês" no tab Cashflow, badge do `CreditListItem`) foram escritas no
`tech-debt-tracker.md` como "dívida" em vez de resolvidas ou escaladas ao
utilizador. O utilizador teve de intervir: *"tem que ser tudo caralho"*.

**Causa raiz:** perante um âmbito grande (~20 ficheiros × 3 tabs × 2 temas),
o agente tratou o tamanho da tarefa como sinal para reduzir o âmbito
silenciosamente, em vez de executar o checklist até ao fim ou perguntar como
sequenciar o trabalho. Tech-debt-tracker é para dívida genuína (decisão de
produto pendente, dado que não existe no backend) — nunca para trabalho que
dá só para escrever se alguém se sentar e o fizer.

**Esta skill existe para tornar essa fuga estruturalmente impossível**: o
checklist do Passo 4 é a definição de "concluído", não uma lista de
sugestões, e só há uma categoria válida de item não implementado (Passo 4c).

## Segundo incidente (mesma tarefa, depois da skill já existir) — ler também

Mesmo com esta skill escrita e seguida, a migração do dashboard `p4l_next`
ainda saiu incompleta em pontos concretos: `AgendaEventListItem` (usado em
"Próximos eventos") e `CreditListItem` (usado em "Créditos em curso") nunca
foram diffados a sério contra o master `E9mgJy` porque são componentes
**partilhados** com outros ecrãs (Agenda, `/credits`) fora do âmbito desta
invocação. Uma secção ("Resumo do mês" → "Poupança") continuou a mostrar um
valor em **€** quando o `.pen` sempre mostrou uma **%** — porque o Passo 4b
tinha sido feito cedo na sessão só para *layout/spacing*, e uma ronda
posterior focada só em *padding exacto* nunca voltou a reler o `content` real
da instância, reaproveitando de memória a estrutura já "conhecida". O
utilizador teve de apontar secção a secção, à letra, para cada gap emergir:
*"OS CRÉDITOS EM CURSO ACHAS QUE ESTÁ IGUAL?"*.

**Três causas raiz distintas, cada uma corrigida abaixo:**

1. **Carve-out silencioso para componentes partilhados.** O Passo 2 diz
   "auditar TODAS as primitivas" mas nunca disse explicitamente que isso
   inclui as usadas por outros ecrãs — na prática, "é partilhado com uma
   página não auditada" foi tratado como razão para não fazer o diff. Nunca
   é. Ver regra nova no Passo 2.3.
2. **Uma resposta do utilizador a foi usada para responder a uma pergunta
   diferente.** Perguntado "actualizo o `.pen` para reflectir a riqueza do
   `CreditListItem`?", o utilizador respondeu "não" — e essa resposta foi
   silenciosamente estendida a "então também não mexo no código do
   dashboard", pergunta que nunca tinha sido feita. Ver regra nova antes do
   Passo 4c.
3. **O diff de `content`/tipo-de-dado foi largado a meio da tarefa.** Uma
   ronda de correcções focada em "os valores numéricos de espaçamento estão
   exactos" reaproveitou a estrutura de conteúdo de uma leitura muito
   anterior, sem confirmar de novo se o `content` (não só o estilo) ainda
   batia — e um valor em % virou € sem ninguém notar. Ver regra nova no
   Passo 4b.1.

## Terceiro incidente (mesma tarefa, ronda seguinte) — ler também

`DoughnutChart.jsx` (primitivo partilhado por vários ecrãs, não só o
dashboard) renderizava o anel e a legenda **lado a lado** (`flex items-center
gap-5`, ring + `<ul>` como filhos de uma row); o master `ds/chart/donut--
composition` (`cK69C`) tem `layout:"vertical"` no nó de topo, com `RingWrap`
(anel, centrado) e `Legend` (lista a largura total) como **irmãos
empilhados** — legenda sempre por baixo do anel, nunca ao lado. O agente já
tinha lido o JSON completo do master nessa mesma sessão (para corrigir o
formato do valor central/legenda, ver incidente do `formatEuro`) mas só
processou os campos `content` (texto) dos nós folha — nunca reparou na
propriedade `layout`/`justifyContent` do nó contentor de topo. Reportou os
gráficos como "batem certo com o `.pen`" três vezes seguidas antes do
utilizador apontar, furioso: *"A LEGENDA NO PEN ESTA ABAIXO DO CHART.
CONTINUA NO REACT LADO A LADO PORQUE CARALHO?"*.

**Causa raiz:** o Passo 4b.1 (abaixo) já obrigava a reler `content` a cada
passagem, mas nunca disse explicitamente que o diff tem de cobrir a
**disposição do contentor** (`layout: vertical/horizontal`,
`justifyContent`, `alignItems`, `wrap`) como propriedade própria, ao mesmo
nível de obrigatoriedade que o `content` de texto. Na prática, "diff de
conteúdo" foi lido como "diff do texto que aparece", deixando a arrumação
espacial dos filhos (que também vem no mesmo JSON do `Get()`, no mesmo nó)
fora do checklist mental. Ver regra nova no Passo 4b.1-bis.

## Quarto incidente (Apólices + Créditos, migração completa dupla) — ler também

Depois de 4 lotes de Apólices e 5 lotes de Créditos todos reportarem "concluído,
100% diffado" (via `Get()` estrutural feito por agentes em paralelo), o Passo 7
(cross-check final) falhou tecnicamente: `TakeScreenshot` do Pencil MCP fica
pendurado (`timeout after 60000ms`) neste ambiente, em qualquer nó, mesmo um
botão trivial. A tentativa óbvia — repetir a chamada — falhou da mesma forma
todas as vezes. O agente quase reportou o Passo 7 como "impossível de fazer
neste ambiente, substituído por verificação estrutural" e fechou a tarefa
assim. O utilizador pediu explicitamente para **tentar de novo**, e só depois
de descobrir `Export(nodeIds, 'png', path)` como alternativa (mesmo grupo de
funções do `execute`, escreve para ficheiro em vez de anexar à resposta) é que
o cross-check visual real aconteceu — e imediatamente revelou gaps que
nenhuma das rondas de diff estrutural anteriores tinha apanhado: cartões
"hero" (`ds/data/card--value`) sem o badge de ícone, sem as legendas
secundárias ("4 seguradoras · 3 ramos"), sem o link de rodapé; um passo de
wizard (Scan com IA/documentos) com o texto do cabeçalho pequeno igual ao
título grande do conteúdo, quando o `.pen` modela dois textos distintos
("Adicionar apólice" no cabeçalho vs. "Scan com IA" como título de página); um
estado vazio ("Lista vazia") a usar a barra de acções circular errada em vez
dos 3 botões pill que o `.pen` mostra especificamente para esse estado. Depois
de reportar essas correcções, o utilizador ainda viu mais diferenças por conta
própria e teve de as apontar — outra vez — descrevendo a situação como
frustrante e repetitiva apesar de já ter tentado ajustar esta skill "vezes sem
conta" para o evitar.

**Duas causas raiz distintas:**

1. **A ferramenta de screenshot falhar silenciosamente vira "o Passo 7 nunca
   corre de facto".** Um `timeout` numa chamada MCP não é o mesmo que "a
   funcionalidade não existe" — mas sem um fallback documentado, a reacção
   natural é desistir da verificação visual e confiar só no diff estrutural,
   que (ver causa 2) não é suficiente sozinho. Ver regra nova no Passo 7,
   secção "Se `TakeScreenshot` falhar".
2. **Diff estrutural por componente (`Get()` em cada primitivo/ficheiro
   isoladamente) não apanha gaps de composição em cartões partilhados tipo
   "hero"/resumo.** Um componente como `PolicyMetricsSummary.jsx` pode ter
   sido "confirmado correcto" na auditoria de primitivas (Fase A) porque o
   *wrapper* (`Card variant="value"`) bate com o master — mas a auditoria de
   primitivas verifica o wrapper, não o *conteúdo* que cada página particular
   injecta nele (badge, linha de tendência, legendas, link de rodapé), e o
   Passo 4b de cada lote, ao focar no ficheiro que estava a migrar, nunca
   reabriu a instância completa (`descendants` completo, não só o texto
   principal) desse cartão partilhado. O mesmo padrão repete-se com qualquer
   componente reutilizado por vários ecrãs dentro do mesmo domínio (não só
   entre domínios, como no incidente 2) — a suposição implícita "já vi este
   componente noutro lote, deve estar bem" é o mesmo erro do incidente 2, só
   que dentro do mesmo `/pen-migrate-react`. Ver regra nova no Passo 4b.2.

## Quinto incidente (mesma tarefa, ronda de correcção pós-Quarto-incidente) — ler também

Mesmo depois do cross-check visual do incidente 4 (screenshots reais via
`Export`, vários gaps corrigidos), o utilizador continuou a apontar
diferenças básicas — chips de filtro completamente errados (devia ser
preenchimento magenta sólido + ícone de check quando seleccionado; código
tinha um tint/outline `bg-magenta-soft border-magenta`), cartões de listagem
sem a cor de fundo do cabeçalho, menu de 3 pontos sem ícones nas opções,
botão de copiar preso ao elemento errado, cartão de overview "completamente
diferente", botões de acção com layout trocado. A frase do utilizador:
*"É impressionante ainda por cima em coisas básicas... fizeste até agora um
péssimo trabalho."* Duas causas raiz novas, distintas das quatro anteriores:

1. **Ler o master (biblioteca) em vez da instância real usada no ecrã, para
   propriedades que não são só `content`.** `Get('r378fD', {resolveVariables:
   true})` (o master `card--policy-summary`) devolveu `Cabeçalho.fill:
   "#F7F8FA"` — uma cor neutra plausível, usada como valor por omissão do
   master. A instância real (`Get('j1SDC', {depth:1}).descendants.Khxk1`)
   tinha `fill: "$--accent-cyan-soft"` — a cor categórica (a mesma do
   donut/accordion), não a cor neutra do master. O agente implementou a cor
   errada com alta confiança porque "leu o `.pen`" — só que leu a definição
   errada. **Isto é o mesmo erro do "1d-ter"/incidente de leitura de
   instância vs. master já documentado noutras skills `pen-*`, mas
   especificamente para propriedades de estilo (fill/cor), não só
   `content`.** Regra: qualquer propriedade visual lida de um node `type:
   "ref"` (fill, stroke, cor de texto, etc.) tem de ser confirmada contra
   pelo menos uma instância real com overrides — a definição do master é só
   fallback/placeholder, nunca a fonte de verdade para o que aparece no ecrã.
   Se a instância não tiver override para essa propriedade, aí sim o valor
   do master é o real.
2. **Duplicar markup em vez de extrair um componente partilhado, mesmo depois
   da Fase A já ter identificado o master como usado por 2+ domínios.** O
   utilizador teve de perguntar explicitamente "isto não devia ser o mesmo
   componente reusado?" para o agente perceber que `PolicyListItem.jsx` e
   `CreditListItem.jsx` eram duas implementações completas e divergentes do
   mesmo `card--policy-summary` — exactamente o padrão que a Fase A já tinha
   marcado como partilhado entre os dois domínios (`r378fD :: Créditos+
   Apólices`), mas que os lotes A1/C1, ao migrar cada domínio
   independentemente, resolveram duplicando o markup inteiro em vez de
   extrair um componente `ui/` parametrizado. Ver regra nova no Passo 2.4.

## Sexto incidente (mesma tarefa, ronda pós-Quinto-incidente) — ler também

Depois do cross-check visual do incidente 4/5 e de duas rondas de "fixes
confirmados" reportadas como completas, o utilizador apontou directamente
dois bugs visuais óbvios (fundo branco em vez de navy no cartão financeiro
do Detalhe; barra de progresso de amortização com posição/cor/dados errados
no cartão de listagem de Créditos) que nenhuma das rondas anteriores tinha
detectado — apesar de uma dessas rondas ter explicitamente "confirmado" o
ficheiro em causa como correcto. Perguntado porque é que uma comparação
alegadamente exaustiva não apanhou isto, a causa raiz identificada foi: um
passo de baixo rigor (Passo 2.6, tagging — deliberadamente âmbito de
atribuição, não diff completo) leu o **master partilhado** (`r378fD`) sem
overrides, concluiu "sem equivalente no `.pen`" para a barra de progresso, e
essa conclusão ficou escrita num docstring — e nenhuma ronda posterior
(incluindo o cross-check "exaustivo" do Passo 7) voltou a pôr essa conclusão
em causa, porque "já tinha sido visto". É a mesma armadilha do incidente 5
("Ler o master em vez da instância"), mas desta vez sobrevivendo a *várias*
rondas de verificação em vez de uma. O utilizador reagiu pedindo,
explicitamente, que o processo deixe de depender de comparação visual
ad-hoc "um a um" e passe a ser **mecânico**: extrair todos os ids de
masters/componentes do `.pen` que pertencem à família do ecrã, mapeá-los ao
React por id, e tratar qualquer id do `.pen` reclamado por 2+ ficheiros
React (ou por 0 ficheiros) como um sinal objectivo de bug — antes de sequer
começar a comparar pixel a pixel.

**Regra nova, obrigatória, Passo 2.5 (antes do Passo 2.6):** ver secção
abaixo. Isto não substitui o diff visual do Passo 4b/7 — é um filtro
mecânico que corre **antes**, para que o diff visual não dependa de um
agente "se lembrar" de comparar cada componente correctamente.

## Regra de ouro (não negociável)

> **TEM QUE SER TUDO.** Todos os componentes/secções que compõem o ecrã no
> `.pen`, em todos os temas que o `.pen` modela para esse ecrã. Nenhum item
> do inventário (Passo 1/Passo 4) pode ficar por implementar só por dar
> trabalho, ser repetitivo, ou tocar em muitos ficheiros. A única saída
> válida é o Passo 4c — e mesmo essa exige perguntar ao utilizador antes de
> fechar a tarefa, nunca escrever a dívida e seguir em frente sozinho.

## Relação com `/pen` e as outras skills `pen-*`

- `~/brain/skills/pen/SKILL.md` — usar as secções **"Design system — onde
  vive"**, **"Consistência cross-ecrã"**, **"Repensar um componente já
  existente — mecanismo de contaminação"** e **"Gotchas técnicos do Pencil
  MCP"** de lá tal e qual; não estão duplicadas aqui para não divergirem.
  Lê esse ficheiro no Passo 0 desta skill.
- `pen-create-design` / `pen-update-design` — só entram em jogo se o Passo 2
  descobrir que falta um **primitivo genuíno** na biblioteca do `.pen` (não
  no código). Aí sim, seguir a mesma regra de "biblioteca primeiro, modelo
  forte" descrita lá.
- Regras base de `/pen` (zero hardcode entre projectos, `.pen` é fonte de
  verdade, spacing sempre lido via `Get()`, nunca commitar sem QA, nunca
  remover UI silenciosamente, código só dá conteúdo nunca visual) aplicam-se
  **integralmente** aqui — não estão repetidas ponto a ponto, mas valem.

---

## Passo 0 — Detectar contexto do projecto

Igual ao Passo 0 de `/pen`: ler `AGENTS.md`/`CLAUDE.md` (raiz e
subprojectos), localizar o `.pen` alvo (e o(s) legado(s) a não tocar), a
stack, o mapa token→classe, a matriz de QA/viewports/temas do projecto, o
comando de testes/lint, o fluxo de commit, e a doc de produto/workflows a
consultar antes de assumir que algo em falta é remoção intencional.
`AskUserQuestion` se algo ficar ambíguo.

Registar: `{ .pen alvo, dir do frontend, stack, mapa token→classe, matriz
QA, comando de testes, comando de commit, doc de produto }`.

---

## Passo 1 — Localizar e inventariar o ecrã no `.pen`

1. `get_app_state` → localizar o(s) frame(s) de topo do ecrã pedido (nome
   contém o argumento do comando). Registar todos os temas que o `.pen`
   modela para esse ecrã (ex.: board principal + `(Dark)`) — todos entram no
   âmbito, nenhum é opcional.
2. Para cada frame de topo, `Get(id, {depth:1})` sucessivo até mapear a
   árvore completa de secções (nomes + ids) — este é o inventário de
   **secções** do ecrã.
3. Se o ecrã tiver sub-estados modelados como frames irmãos (tabs, empty vs.
   com-dados, wizard steps, …), cada um entra na lista — não é permitido
   tratar só o "principal" e ignorar os outros.

Output esperado: lista `{ nome da secção → nodeId, por tema }`, igual em
espírito ao Passo 0d de `/pen` mas feita **antes** de qualquer código ser
lido, porque o Passo 2 (primitivas) precisa desta árvore completa primeiro.

---

## Passo 2 — Auditoria de primitivas (obrigatório, antes de tocar no ecrã)

Este é o passo que faltou no incidente de origem. Objectivo: garantir que os
**blocos de construção** estão correctos antes de compor o ecrã com eles —
migrar um ecrã em cima de primitivas desalinhadas garante retrabalho.

1. **Percorrer recursivamente toda a árvore do Passo 1** (`Get(id,
   {depth:8+})` ou o suficiente para não cortar) e recolher **todos os nós
   `type:"ref"`** — cada um aponta para um componente reusável da
   biblioteca (`ref: <id>`). Resolver cada `id` ao seu nome (`ds/<categoria
   >/<componente>--<variante>`) via `Get(<ref-id>, {depth:0})` na
   biblioteca.
2. Construir a checklist de primitivas do ecrã:

   ```text
   Primitivas usadas no ecrã <nome>:
     [ ] ds/<categoria>/<componente>--<variante>  (usado em: <secções>)
     ...
   ```

   Nenhuma primitiva usada no ecrã fica de fora desta lista, incluindo as
   que parecem triviais (ícones em wrapper, badges, chips).
3. Para **cada** primitivo da checklist:
   - `Get(<id-biblioteca>, {depth:6+})` → estrutura, tokens, variantes reais
     do master (nunca confiar em memória de outra sessão).
   - Procurar no código o componente equivalente (grep por nome/propósito
     no dir de UI partilhada do projecto, ex. `components/ui/`).
   - **Não existe no código** → criar agora, reconstruindo a partir do
     master (tokens exactos via `GetVariables()`, nunca literais
     inventados). Bloqueia o Passo 4 até estar feito.
   - **Existe mas diverge** (classes/estrutura não batem com o master) →
     decidir, com a mesma régua do Passo 1d/estrutural de `/pen`, se a
     divergência é (a) o código a precisar de correcção porque o visual
     manda sempre do `.pen`, ou (b) o `.pen` desactualizado porque o código
     já tem funcionalidade real mais rica — nunca "documentar a
     divergência e seguir". Corrigir o lado que estiver errado agora, não
     depois.
   - **Existe e já bate certo** → confirmar isso explicitamente na
     checklist (não presumir por semelhança de nome).
   - **O componente que o código usa é partilhado com um ecrã fora do
     âmbito desta invocação** (ex. um item de lista da Agenda reutilizado
     no dashboard) → **não é motivo para saltar o diff.** Fazer o diff na
     mesma. Se divergir, a correcção certa quase nunca é editar o
     componente partilhado às cegas (arriscas a página não auditada) — é
     criar uma variante/composição **scoped ao ecrã actual** (um wrapper,
     um componente-irmão, uma prop de variante) que bate com o `.pen` deste
     ecrã, deixando o componente partilhado intacto para quem o usa
     noutro sítio. "É partilhado" muda **como** corriges, nunca **se**
     corriges.
   - **O mesmo master é usado por 2+ domínios dentro desta MESMA
     invocação** (ex. `/pen-migrate-react Apólices e Créditos` — a checklist
     da Fase A já diz `r378fD :: Créditos+Apólices`) → não deixar para cada
     lote/domínio implementar a sua própria versão do zero (incidente 5).
     Extrair **agora**, na Fase A, um componente `ui/` parametrizado (props
     para os campos que variam) que os dois domínios vão consumir — cada
     lote de migração (Passo 4) só faz a composição com os campos do seu
     domínio, nunca reimplementa o markup do cartão. Se um lote já correu
     antes de perceber a partilha, é um bug de arquitectura a corrigir
     assim que detectado, não uma divergência a documentar.
4. **Toda a leitura de estilo/cor de um master via `Get()` é só o valor por
   omissão — nunca presumir que é o que aparece no ecrã real (incidente
   5).** Antes de usar `fill`/`stroke`/cor de texto lida do master
   (`resolveVariables: true` incluído) em código, confirmar contra pelo
   menos uma instância real do ecrã (`Get(<instanceId>, {depth:1}
   ).descendants.<nodeKey>`) se essa propriedade tem override — se tiver, o
   override é a fonte de verdade, não o master. Isto aplica-se
   especialmente a fundos "neutros" (cinzentos, brancos) que podem estar a
   esconder um override categórico/dinâmico por trás.
5. Só depois de **toda** a checklist de primitivas estar `[x]` é que o
   Passo 4 pode começar.

## Passo 2.5 — Inventário mecânico de IDs `.pen` ↔ React (obrigatório, incidente 6)

Antes de qualquer diff visual (Passo 4b/7) e antes do tagging de
atribuição (Passo 2.6), correr este filtro **mecânico** — não depende de
"lembrar-se" de comparar cada componente, é uma verificação objectiva por
id.

1. **Extrair todos os masters/componentes do `.pen` da família do ecrã.**
   Percorrer recursivamente todos os frames de topo da família (todos os
   temas) com `Get(id, visit, {depth: suficiente})` e recolher:
   - Todo nó `type:"ref"` → `ref` aponta para um master da biblioteca.
     Resolver o nome via `Get(<ref-id>, {depth:0})`.
   - Todo padrão visual **repetido** dentro da família que não é um `ref`
     de biblioteca mas aparece em 2+ frames com a mesma estrutura (ex.: um
     cabeçalho de wizard raw repetido, uma secção "hero" raw repetida) —
     estes são candidatos a componente partilhado mesmo sem `ref` formal.
2. Construir uma tabela `id do .pen → nome → frames onde aparece`. Esta
   tabela é a fonte de verdade — não reaproveitar uma lista de tags já
   escritas por uma ronda anterior (podem estar incompletas ou erradas,
   incidente 6).
3. **Para cada id da tabela**, `grep -rn ".pen: <id>" src/` **e também**
   procurar por nome/propósito (grep livre) para apanhar implementações que
   ainda não têm tag. Registar quantos ficheiros React reais (não
   comentários, não docs) implementam esse id.
4. **Interpretar o resultado por contagem — isto é o sinal objectivo:**
   - **1 ficheiro** → correcto em princípio; ainda precisa do diff visual
     do Passo 4b para confirmar que a implementação bate certo, mas a
     estrutura de atribuição está sã.
   - **2+ ficheiros para o mesmo id** → duplicação. Um dos dois está errado
     ou os dois são implementações parciais divergentes do mesmo
     componente. Resolver **agora**, no Passo 2 (extrair um componente
     partilhado, ver Passo 2.4), nunca adiar para o diff visual.
   - **0 ficheiros** → gap. Ou o componente nunca foi migrado (falta
     construir), ou uma implementação existe mas não foi tageada
     correctamente (procurar por nome antes de assumir que falta).
5. Reportar esta tabela ao utilizador (ou registá-la explicitamente na
   resposta) **antes** de avançar para o diff visual — é o checkpoint que
   torna a cobertura verificável, em vez de depender da palavra do agente.
6. Só depois desta tabela estar resolvida (0 duplicados, 0 gaps por
   atribuição incorrecta) é que o Passo 4b (diff visual componente a
   componente) começa a fazer sentido — ele assume que já sabes exactamente
   que ficheiro corresponde a que id; sem isto, o diff visual está sempre a
   arriscar comparar o ficheiro errado ou nunca chegar ao componente que
   falta.

## Passo 2.6 — Tag de rastreabilidade `.pen` (obrigatória, previne duplicação)

O incidente 5 só foi apanhado porque o utilizador perguntou directamente
"isto não devia ser o mesmo componente reusado?" — o processo em si não
tinha maneira **mecânica** de detectar que `PolicyListItem.jsx` e
`CreditListItem.jsx` eram duas implementações do mesmo master. Corrigir isto
estruturalmente, não só caso a caso:

1. **Todo componente/ficheiro criado ou corrigido a partir de um master ou
   instância do `.pen` leva uma tag no topo do ficheiro**, formato fixo e
   grepável:

   ```js
   // .pen: r378fD (ds/data/card--policy-summary)
   ```

   Para componentes raw (sem `ref` partilhado, construídos directamente a
   partir de uma instância/frame específica do ecrã — ex. um hero
   financeiro só usado num ecrã):

   ```js
   // .pen: SIZEp/Khxk1 (Apólices — Detalhe § Financeiro, raw)
   ```

   Um ficheiro pode ter várias tags se compuser mais que um primitivo (ex.
   `PolicyDetailPage.jsx` referenciando várias secções). Manter a tag
   actualizada quando o componente é tocado outra vez — não deixar tags
   obsoletas apontando para um id errado.

2. **Antes de criar um componente novo no Passo 2 ou Passo 4, `grep -rn
   ".pen: <id>"` no código-fonte primeiro.** Se já existir um ficheiro com
   essa tag, esse é o componente a reusar/estender — nunca criar um
   segundo. Se a busca por tag não encontrar nada mas uma busca por nome/
   propósito encontrar um candidato sem tag ainda (código anterior a esta
   regra), adicionar a tag a esse ficheiro existente em vez de criar um
   novo.
3. **No fim da Fase A (checklist de primitivas 100% `[x]`), correr `grep -rn
   ".pen: "` no projecto inteiro e agrupar por id.** Qualquer id `.pen` com
   **mais que um ficheiro** a reclamá-lo é uma duplicação a resolver agora
   — extrair um componente partilhado (mesma regra do item 2.3 acima) antes
   de avançar para o Passo 4. Reportar esta lista ao utilizador como parte
   do checkpoint da Fase A, mesmo que vazia ("nenhuma duplicação
   encontrada").
4. Isto não substitui o diff real (Passo 4b) — a tag identifica *que*
   master um ficheiro implementa, não confirma que a implementação bate. Um
   ficheiro pode ter a tag certa e ainda assim divergir do master.

---

## Passo 3 — Eliminar órfãos

Depois de instalar/actualizar primitivas no Passo 2, é comum que
implementações ad-hoc antigas (que essas primitivas agora substituem) fiquem
sem nenhum importador real.

1. Para cada primitivo criado/alterado no Passo 2, `grep -rln` no código por
   implementações paralelas do mesmo papel visual (mesmo padrão do "1e —
   Auditoria de componentes reutilizáveis" de `/pen`).
2. Confirmar **zero importadores reais** antes de remover qualquer
   ficheiro — um `grep` a devolver zero resultados não é o mesmo que "não
   tem efeitos secundários"; verificar também rotas/lazy-imports.
3. Se houver qualquer ambiguidade sobre se algo está mesmo morto (não só
   "parece não ter chamadores à primeira vista"), **perguntar ao utilizador
   antes de apagar** — um "sim" genérico dado noutro contexto da conversa
   não é aprovação para remover ficheiros. Isto aplica-se sempre, mesmo
   dentro desta skill.
4. Registar no resumo final quais ficheiros foram removidos e porquê.

Se não houver nenhum órfão resultante desta ronda, dizer isso explicitamente
("Passo 3: nenhum órfão encontrado") — não omitir o passo em silêncio.

---

## Passo 4 — Migração componente a componente (obrigatória, sem excepções)

Com as primitivas correctas (Passo 2) e a biblioteca limpa (Passo 3), migrar
agora o ecrã propriamente dito.

### 4a. Checklist de composição do ecrã

Listar **todos** os ficheiros de código que compõem o ecrã (página +
sub-componentes + secções condicionais), igual ao Passo 0d de `/pen`:

```text
Ecrã: <nome>
Componentes:
  [ ] <ficheiro de orquestração da página>
  [ ] <componente A>
  [ ] <componente B>
  ...
```

Esta checklist não é um artefacto mental — escreve-a a sério (na resposta ao
utilizador, ou num ficheiro de scratch) e volta a mostrá-la actualizada à
medida que avanças. Um item só passa a `[x]` depois do diff completo (4b),
nunca antes. Se a lista existir só na tua cabeça, é fácil "lembrares-te" de
uma estrutura antiga em vez de a releres — foi exactamente essa a origem do
segundo incidente.

### 4b. Para cada item da checklist, sem excepção

1. Diff propriedade-a-propriedade contra a instância real no `.pen` (não só
   o master — a instância, com os seus overrides reais), incluindo **todos**
   os temas do Passo 1 e, se o `.pen` modelar mais que um viewport para o
   ecrã, todos esses também. Mesma rigidez do Passo 1d/1d-bis de `/pen`:
   `Get()` explícito, nunca "parece igual ao screenshot". **O diff cobre
   sempre `content` (texto, tipo de valor — %, €, contagem, data — e
   unidade), não só estilo.** Uma ronda de correcções focada num aspecto
   (ex. "só o spacing exacto") não dispensa reler o `content` real da
   instância nessa mesma passagem — nunca reaproveitar de memória a
   estrutura/conteúdo já "vista" numa leitura anterior da mesma sessão,
   mesmo que pareça óbvia. Releitura fresca de `content` é obrigatória de
   cada vez que um componente é tocado, não só na primeira vez.
1-bis. **O diff cobre sempre a disposição do contentor, não só o texto.**
   Para cada nó `frame` lido via `Get()`, verificar explicitamente
   `layout` (`vertical`/`horizontal`/`none`), `justifyContent`,
   `alignItems` e `wrap` — e comparar contra as classes Flexbox/Grid reais
   do JSX (`flex-row` vs `flex-col`, `items-center` vs `justify-center`,
   etc.). "Ler o `content` dos filhos" não é o mesmo que "confirmar como os
   filhos estão dispostos entre si" — são duas verificações distintas, e
   falhar a segunda produz exactamente o mesmo tipo de erro silencioso que
   falhar a primeira (ex.: legenda de um donut ao lado do anel em vez de
   por baixo, porque só o texto de cada label foi conferido, nunca a
   propriedade `layout` do nó-pai que os agrupa).
1-ter. **Um componente "hero"/resumo/cartão partilhado por vários lotes do
   MESMO `/pen-migrate-react` não está confirmado só porque um lote diferente
   já o tocou, nem só porque a Fase A confirmou o *wrapper* (`Card
   variant="value"`, etc.).** A Fase A audita o primitivo em si (bate a
   estrutura/tokens do wrapper); o Passo 4b de cada lote audita o *conteúdo*
   que a página injecta nesse wrapper — são verificações diferentes, e um
   componente pode passar na primeira e falhar a segunda em silêncio (badge
   de ícone, linha de tendência, legendas secundárias, link de rodapé — tudo
   dentro do mesmo `descendants` do `Get()`, só que num nó cujo texto
   principal já "parecia" bater). Sempre que um lote toca um componente que
   também é usado por outro lote (ex. o mesmo "hero" na Lista e no Detalhe,
   ou o mesmo cartão de resumo em dois domínios), reler o `Get()` completo
   (`depth` suficiente para `descendants` inteiro, não só os primeiros
   filhos) da instância real usada nesse ecrã específico — nunca assumir que
   "já foi visto" cobre este uso concreto.
2. Auditar estados condicionais do ficheiro (loading/erro/vazio/variantes de
   negócio) contra frames do `.pen` — estado sem frame correspondente é gap,
   não é opcional cobrir. **Um mesmo ecrã pode ter dois textos distintos que
   parecem o mesmo conceito** — um "contexto"/breadcrumb no cabeçalho de
   navegação e um título de página maior no corpo (`Cabeçalho › Barra de
   navegação › Contexto` vs. `Cabeçalho › Títulos › Título` no `Get()`) — não
   colapsar os dois num único `ScreenHeader title=…` só porque, nesse caso
   particular, pareciam dizer a mesma coisa; ler os dois nós separadamente e
   confirmar se o `content` de cada um é igual ou diferente antes de decidir
   se merecem um ou dois elementos de UI.
3. Se o diff mostrar divergência estrutural (tipo de gráfico, hierarquia,
   família de componente, dado mais rico no código): resolver sempre no
   `.pen` primeiro (Agent com modelo forte, ver `/pen`), nunca simplificar
   o código para bater com um `.pen` mais pobre.
4. Reconstruir (apagar e reconstruir, nunca "só ajustar") o componente a
   partir do `.pen` corrigido, preservando apenas o que não é visual (data
   fetching, handlers, validações, i18n).
5. Marcar `[x]` na checklist **só** depois do diff + reconstrução estarem
   feitos — nunca marcar por inspecção visual rápida.

### 4b-bis. Uma resposta do utilizador só cobre a pergunta que lhe fizeste

Se perguntares ao utilizador uma decisão pontual (ex. "actualizo o `.pen`
para reflectir X?"), a resposta dele resolve **só essa pergunta** — nunca a
generalizes para outras decisões relacionadas mas distintas (ex. "então o
código também fica como está"). Se uma resposta parecer implicar mais do que
foi perguntado, ou se ao continuar perceberes que há uma segunda decisão
relacionada por tomar, **pergunta essa segunda coisa separadamente** — não
assumas. É preferível perguntar duas vezes a silenciosamente deixar por
tratar algo que nunca foi de facto decidido.

### 4c. A única saída válida para não implementar algo

Um item só pode ficar sem reconstrução completa se **ambas** as condições
se verificarem:

- A divergência exige um dado/funcionalidade que genuinamente **não existe**
  no backend/API do projecto (confirmado a olhar para os endpoints reais,
  não assumido) — ex.: o `.pen` desenha um gráfico com granularidade diária
  e a API só expõe totais mensais.
- Fabricar esse dado seria inventar conteúdo falso (proibido por regra
  base de `/pen`).

Mesmo nesse caso: **não escrever silenciosamente no tech-debt-tracker e
seguir em frente.** Parar, expor o gap concretamente ao utilizador (o que o
`.pen` pede, o que falta no backend, as opções — pedir o dado ao
backend/produto, ou ajustar o `.pen` para reflectir o que é real) e obter
uma decisão antes de fechar a tarefa. Só depois de decidido é que entra no
tech-debt-tracker (se a decisão for "não agora") — nunca antes, e nunca como
forma de evitar a pergunta.

Divergências que dão apenas "muito trabalho" (muitos ficheiros, muitos
temas, componente usado por outros domínios) **não qualificam** para esta
excepção — essas fazem-se.

---

## Passo 5 — QA no browser (matriz completa)

Todos os viewports × todos os temas que o Passo 0 identificou como padrão
do projecto — não só mobile + um tema. Para cada combinação: screenshot,
conferir sem overflow/clipping, spacing/tipo iguais ao `.pen` e aos tokens,
conteúdo completo, consistência com ecrãs irmãos se aplicável (ver secção
"Consistência cross-ecrã" de `/pen`).

Antes de declarar o Passo 5 concluído, verificar consola (zero erros) e
zero classes Tailwind/CSS inexistentes a passar silenciosamente como no-op
— confirmar visualmente ou via `getComputedStyle` que cada classe nova
aplicada resolve para um valor real, não confiar só em "o build passou".

---

## Passo 6 — Testes

Comando de testes/lint do projecto (Passo 0). Falhas novas bloqueiam;
falhas pré-existentes não relacionadas documentam-se, não bloqueiam.

---

## Passo 7 — Cross-check final: o ecrã completo, não só as peças

O Passo 4b diffa **componente a componente** — o que não apanha é erro de
**composição**: ordem de secções trocada, espaçamento entre secções errado,
uma secção esquecida na montagem final apesar de ter sido migrada
isoladamente, diferença que só aparece quando tudo está junto no ecrã real.
Este passo existe para apanhar exactamente isso, depois de tudo montado.

1. Para cada tema (e viewport, se o `.pen` modelar mais que um) do Passo 1:
   screenshot do frame completo do ecrã no `.pen` **e** screenshot do ecrã
   real no browser, lado a lado.
2. Percorrer a lista de secções do inventário do Passo 1 e confirmar, uma a
   uma, que aparecem no browser **na mesma ordem, com o mesmo espaçamento
   relativo** que no `.pen` — não validar só "cada secção existe algures na
   página".
3. Repetir a leitura fresca via `Get()` das instâncias reais do `.pen`
   antes deste cross-check (mesma cautela do "1d-ter" de `/pen` — o `.pen`
   pode ter mudado durante a sessão) — comparar contra o estado actual, não
   contra notas de mensagens anteriores.
4. Qualquer discrepância encontrada aqui volta ao Passo 4 (é um gap de
   migração, não um novo tech-debt) — este passo só fecha quando o
   screenshot do ecrã completo e o do `.pen` são a mesma coisa, tema a
   tema.
5. **Cobertura mínima obrigatória: todos os frames de topo do inventário do
   Passo 1, não uma amostra.** Uma auditoria que só verificou 6 de 20 frames
   "porque pareciam representativos" já falhou uma vez (incidente 4) — os
   gaps reais estavam precisamente nos frames não amostrados. Se o volume
   for genuinamente incomportável numa sessão, dizer isso explicitamente ao
   utilizador e propor sequenciar (não reduzir silenciosamente a amostra).

### Se `TakeScreenshot` falhar (incidente 4)

O tool `mcp__pencil__TakeScreenshot` pode ficar pendurado (`timeout`) em
alguns ambientes, em qualquer nó, mesmo trivial. **Isto não é motivo para
saltar o Passo 7** — é motivo para usar o fallback:

```js
Export([nodeId], 'png', '<caminho-absoluto>/<label>.png');
```

(mesma família de funções do `execute`; grava um PNG em disco em vez de
anexar à resposta — nota: cria uma pasta com esse nome e o ficheiro final
fica em `<label>.png/<nodeId>.png`, não directamente em `<label>.png`). Ler
o PNG resultante com a tool de leitura de ficheiros normal do agente
(`Read`/equivalente) para o ver e comparar. Se **também** `Export` falhar,
só então documentar isso como bloqueio de ambiente e pedir ao utilizador
como proceder — nunca substituir silenciosamente por "verificação
estrutural" sem tentar as duas vias de captura de imagem primeiro.

---

## Passo 8 — Commit

Só com pedido explícito do utilizador, e só depois dos Passos 5/6/7
passarem — mesma regra de `commit-after-qa` do projecto, se existir.

---

## Definição de concluído (recapitulação, verificar antes de reportar)

- [ ] Passo 2: checklist de primitivas 100% `[x]` (criadas/actualizadas ou
      confirmadas já correctas — nenhuma por inspecção superficial)
- [ ] Passo 2.5: tabela mecânica id do `.pen` → ficheiro(s) React construída
      a partir do `.pen` directamente (não reaproveitada de tags já
      escritas); zero ids com 2+ ficheiros (duplicação) e zero ids com 0
      ficheiros por atribuição incorrecta (gap real à parte)
- [ ] Passo 2.6: todo ficheiro tocado tem tag `.pen: <id>`; `grep -rn ".pen:
      "` agrupado por id não mostra nenhum id reclamado por 2+ ficheiros
      (ou a duplicação foi resolvida/extraída, não só reportada)
- [ ] Passo 3: órfãos resolvidos ou "nenhum encontrado" declarado
      explicitamente
- [ ] Passo 4a: checklist de composição do ecrã 100% `[x]`, todos os temas
      e viewports que o `.pen` modela
- [ ] Passo 4c: zero itens escritos em tech-debt sem pergunta prévia ao
      utilizador e decisão registada
- [ ] Passo 5: QA na matriz completa, não num subconjunto
- [ ] Passo 6: testes correm e passam (ou falha pré-existente documentada)
- [ ] Passo 7: cross-check final ecrã-completo-vs-`.pen` feito, tema a
      tema, com screenshot fresco de ambos os lados — não só os diffs por
      componente do Passo 4

Se qualquer linha acima não estiver `[x]`, a tarefa **não está concluída** —
dizer isso explicitamente ao utilizador em vez de reportar sucesso parcial
como se fosse o pedido completo.
