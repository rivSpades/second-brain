---
name: pen-update-design
description: >
  Audita e corrige um design system já existente num ficheiro `.pen` de um
  projecto (qualquer frontend) contra o baseline obrigatório de
  checklist.design/design-system (28 itens: 4 foundations + 24 components),
  verificado sempre contra a biblioteca local (~/brain/raw/checklist-design/),
  nunca contra o site ao vivo. Modo diff-and-patch: assume que
  /pen-create-design (ou trabalho manual) já construiu algo antes — só toca no
  que está em falta (❌) ou incompleto (⚠️), nunca reescreve o que já cumpre
  (✅). Genérica — não assume projecto, paleta, stack nem estrutura de pastas
  específicos; deriva tudo do `.pen` e do contexto do projecto
  (AGENTS.md/CLAUDE.md) em cada invocação. Invoca sem argumentos: /pen-update-design
  — usa sempre o estilo/designer já estabelecido no `.pen` alvo, nunca pede ou
  aceita um nome de designer (isso seria mudança de âmbito, ver
  `/pen-create-design`). Workflow: detectar projecto + `.pen` alvo → confirmar
  que já há design estabelecido → diff (gaps novos / regressões / biblioteca
  desactualizada) → ler biblioteca local → cross-check por item → corrigir no
  `.pen` (Opus) → reconstruir só o código afectado → QA → testes → commit (só
  se pedido).
---

# pen-update-design — Corrigir/completar um design system já existente num `.pen`

> Skill **genérica** (vive em `~/brain/skills/`, não num projecto). Nada aqui é
> específico de um projecto — cada invocação deriva paths, paleta, stack e
> convenções do projecto actual. Não copiar valores de uma sessão anterior
> "de memória" para outro projecto.
>
> Esta skill é o par diff-and-patch de **`pen-create-design`** — mesma
> numeração e títulos de Passos onde o conteúdo é partilhado, para permitir
> `diff` directo entre os dois ficheiros e detectar deriva entre eles ao longo
> do tempo. Se algo aqui parecer desactualizado face a `pen-create-design`,
> tratar isso como um bug a corrigir nesta skill, não como intencional.

## O que esta skill é (e não é)

- **É** um workflow de manutenção: audita o `.pen` alvo e o código de um
  projecto contra o mesmo baseline obrigatório de `pen-create-design` (os 28
  itens de `checklist.design/design-system`), e corrige **só** o que está
  `❌`/`⚠️` — nunca retrabalha o que já está `✅`.
- **Não é** para arrancar um design system do zero. Se o `.pen` alvo estiver
  vazio/genérico (sem nenhum sinal de estilo estabelecido), esta skill não
  bloqueia silenciosamente — sugere ao utilizador correr `/pen-create-design`
  primeiro.
- **Não é** dona do `.pen` legado do projecto. Mesma regra que
  `pen-create-design`: se existir um `.pen` "oficial" diferente do alvo, fora
  de âmbito, não mexer.
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
| id + anotação já vêm no `.pen` | Componentes seguem tipicamente `ds/<categoria>/<componente>--<variante>` com uma anotação de texto ao lado com a string de classes literal — ler essa anotação em vez de adivinhar; se o `.pen` do projecto usar outra convenção, seguir a dele |
| Baseline obrigatório = checklist.design/design-system | Os mesmos 4 foundations + 24 components (28 itens) que `pen-create-design` usa — sempre auditados nesta corrida |
| Fonte da checklist = só a biblioteca local | `~/brain/raw/checklist-design/` — **nunca** aceder a checklist.design ao vivo a partir desta skill |
| **Não tocar no que já está `✅`** | Ao contrário de `pen-create-design` (autorizada a construir tudo de raiz), esta skill só mexe em `❌`/`⚠️` — reescrever algo já conforme sem motivo é regressão, não manutenção |
| Sem design estabelecido → sugerir create-design | Não inventar um estilo do zero aqui; ver secção "O que esta skill não é" |
| Apagar e reconstruir (só o afectado), nunca "aproximar" editando | Ver Passo 5 |
| Nunca commitar sem QA | Confirmar visualmente (browser ou o método de preview do projecto) antes de qualquer commit |
| Nunca remover UI/lógica silenciosamente | Preservar hooks, data fetching, handlers, estados condicionais — só a camada visual muda |
| Não commitar sem pedido explícito | Usar o fluxo de commit do próprio projecto (skill local, se existir) só quando o utilizador pedir |

---

## Guardrails anti-"AI slop" (aplicar sempre, em qualquer Passo 4/5, qualquer projecto)

> Fonte: skill pública [tasteskill.dev](https://www.tasteskill.dev/docs) / repo
> [Leonxlnx/taste-skill](https://github.com/Leonxlnx/taste-skill) — catálogo de padrões
> visuais e de copy que denunciam design gerado por IA sem curadoria. Aplica-se a
> **qualquer** projecto/estilo corrigido por esta skill, não é opcional — o estilo já
> estabelecido no `.pen` determina a estética, estas regras determinam se a correcção
> mantém essa estética intencional ou introduz regressões genéricas.

**Cor**
- Máximo 1 accent color por `.pen`. Variações do mesmo accent (tom/opacidade) sim; uma
  segunda cor de destaque "para variar", não.
- Evitar roxo/violeta ou glow azul-roxo como accent por defeito ("Lila Rule") — é o tell
  visual mais comum de design gerado por IA sem curadoria. Só usar se o estilo já
  estabelecido no `.pen` o exigir explicitamente.
- Sem preto puro (`#000000`) nem branco puro (`#FFFFFF`) nos tokens base — usar
  off-black/off-white.
- Sem glow externo por defeito. Acabamento premium/"glass": borda interior subtil +
  sombra interior, não halo colorido à volta do elemento.
- Color Consistency Lock: o accent já estabelecido usa-se em toda a página, nunca troca
  de secção para secção — se a auditoria (Passo 1) encontrar uma segunda cor de destaque
  a aparecer, isso é uma regressão a corrigir, não uma variante válida.

**Forma e tema**
- Shape Consistency Lock: um único sistema de raio de canto por `.pen` — divergências
  encontradas na auditoria são regressão, corrigir para o sistema já estabelecido.
- Page Theme Lock: um tema por página (não inverter light/dark a meio do scroll), salvo
  excepção deliberada já documentada no `.pen`.

**Composição** (relevante ao corrigir ecrãs inteiros, não só componentes — ver Passo 9)
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

**Copy visível ao utilizador** (quando esta skill também revê texto de UI)
- Travessão (`—`/`–`) banido de todo o texto visível — títulos, botões, legendas, texto
  de estado. Reestruturar com ponto, vírgula ou dois pontos. Não se aplica a documentação
  interna do projecto (specs, PRDs, notas).
- Sem verbos de enchimento genéricos ("revolucionar", "elevar o potencial") nem números
  inventados com precisão falsa (`99%`, `4.2x`) sem fonte real.

Ao classificar o Passo 1 (auditoria em modo diff), tratar qualquer violação destas regras
como **regressão** (mesmo que o item de checklist correspondente esteja `✅`) — corrigir
no mesmo Passo 4 que os gaps normais.

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

## Passo 0.5 — Confirmar que já existe estilo estabelecido (não recriar, não aceitar designer novo)

```js
get_app_state({ include_schema: false, include_canvas_design: true,
                include_scripts_and_shaders: false, include_browser: false })
// filePath: <.pen alvo detectado no Passo 0>
```

Esta skill **não tem parâmetro de designer** — usa sempre o que já está
definido no `.pen` alvo, nunca pergunta nem aceita um nome novo.

1. Procurar sinais de estilo já estabelecido no `.pen` alvo (frame de
   foundations, anotações, variables de cor/glow/gradiente, nome do ficheiro).
2. **Se não houver nenhum sinal** (`.pen` vazio/genérico): parar aqui e
   informar o utilizador que não há design estabelecido para actualizar —
   sugerir `/pen-create-design [nome_designer]` em vez de continuar (é essa
   skill, não esta, que define um designer pela primeira vez).
3. Caso contrário, continuar com o estilo já estabelecido — esta skill nunca
   muda de designer/estética, só completa/corrige o que já está definido.

## Passo 1 — Auditoria em modo diff (os 28 itens obrigatórios)

Mesma tabela fixa de 28 itens que `pen-create-design` usa (4 foundations + 24
components, slugs em `https://www.checklist.design/design-system/<slug>` —
ver a lista completa no Passo 1 dessa skill). Para cada item, classificar em
três categorias, não só `✅/⚠️/❌`:

| Item | Slug | Estado | Categoria de diff |
|------|------|--------|--------------------|
| … | … | ✅/⚠️/❌ | gap novo / regressão / biblioteca desactualizada |

- **Gap novo**: nunca foi construído (equivalente a `❌` numa primeira corrida).
- **Regressão**: estava `✅` numa corrida anterior, mas o código evoluiu e
  deixou de cumprir (ex.: alguém adicionou um botão novo que não segue o `.pen`).
- **Biblioteca desactualizada**: há uma suspeita de que o próprio
  checklist.design mudou/adicionou itens desde a última extracção da
  biblioteca local, e o ficheiro em `~/brain/raw/checklist-design/` já não
  reflecte isso. Nesse caso, **não ir buscar ao site a partir desta skill** —
  sinalizar ao utilizador que pode valer a pena um refresh manual da biblioteca
  (apagar o ficheiro e voltar a extrair), e continuar com o que a biblioteca
  local tem por agora.

## Passo 2 — Ler a biblioteca local (nunca o site ao vivo)

Só para os itens `❌`/`⚠️` do Passo 1:

```
Read ~/brain/raw/checklist-design/design-system/<slug>.md
```

Mesma regra que `pen-create-design`: esta skill nunca acede a
`checklist.design` ao vivo. A biblioteca em `~/brain/raw/checklist-design/` é a
única fonte.

## Passo 3 — Cross-check por item de checklist (só os afectados)

Igual ao Passo 3 de `pen-create-design`, mas só para os itens `❌`/`⚠️`:

| Item checklist | Cumprido no `.pen`? | Cumprido no código? | Evidência |
|-----------------|----------------------|------------------------|-----------|
| … | ✅/⚠️/❌ | ✅/⚠️/❌ | `Get(nodeId)` / ficheiro:linha |

## Repensar um componente já existente (não gap novo) — mecanismo de contaminação

Aplica-se sempre que o pedido é "este componente está mal, repensa-o" — não a
preencher um gap `❌`/`⚠️` do baseline nem a fundir/deduplicar masters
preservando o visual (isso é mecânico, sem risco de contaminação criativa).
Nota: numa corrida normal desta skill (diff-and-patch), a maior parte dos
itens `⚠️`/`❌` são gaps de cobertura — esta secção só entra em jogo quando o
próprio utilizador pede explicitamente para repensar um componente existente,
não como parte do fluxo automático de correcção.

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

## Passo 4 — Corrigir no `.pen` alvo (`Agent(model:"opus")`) — só ❌/⚠️

```
Agent({
  model: "opus",
  description: "Corrigir <.pen alvo> — <foundation/component>",
  prompt: """
    .pen: <path exacto do .pen alvo detectado no Passo 0>
    (NUNCA o .pen legado: <path, se existir>)
    Estilo já estabelecido: <confirmado no Passo 0.5 — não mudar>
    Componente/foundation: <nome> (checklist.design/design-system/<slug>)

    Itens da checklist ainda não cumpridos (lidos de
    ~/brain/raw/checklist-design/design-system/<slug>.md — Checklist +
    Documentation):
      <lista de itens ❌/⚠️ com a descrição de cada um>

    IMPORTANTE: não reescrever nem tocar em nada que já esteja `✅` no Passo 3
    — só os itens listados acima. Seguir a convenção de id + anotação já usada
    no ficheiro (ver componentes vizinhos já existentes). Tokens base já
    definidos no .pen (GetVariables()) — reutilizar, não duplicar. Registar
    qualquer componente novo no inventário existente.
  """
})
```

## Passo 5 — Reconstruir só o código afectado (apagar e reconstruir, nunca "aproximar")

Igual ao Passo 5 de `pen-create-design`, mas **só nos ficheiros/componentes
cujo item de checklist ficou `❌`/`⚠️`** no Passo 1/3 — não retrabalhar
ficheiros já conformes:

1. Ler o ficheiro actual por completo — preservar tudo o que não é visual
   (hooks, data fetching, handlers, lógica de estado, chaves de i18n/copy).
2. Apagar o markup/classes visuais existentes.
3. Reconstruir a partir da anotação do componente no `.pen` (Passo 4) —
   classes/valores exactos, incluindo variante de tema quando divergir.
4. Se existir um primitivo reutilizável no projecto — actualizar esse
   primitivo em vez de duplicar estilo inline.
5. Não remover estados condicionais (loading/error/empty) — só re-estilizar.

---

## Passo 6 — QA

Igual ao Passo 6 de `pen-create-design`: viewports/temas relevantes do
projecto, sem overflow/clipping, efeitos visuais a renderizar, cores correctas
no tema escuro, conteúdo/estados completos. Se não houver ferramenta de preview
disponível, dizer isso explicitamente em vez de simular QA.

## Passo 7 — Testes

Correr o comando de testes/lint que o `AGENTS.md`/`package.json` (ou
equivalente) do projecto define. Falhas pré-existentes não relacionadas:
documentar, não bloquear. Falhas novas: corrigir antes de continuar.

## Passo 8 — Commit (só se o utilizador pedir)

Usar o fluxo de commit próprio do projecto (skill local tipo `/commit-push`, se
existir).

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
| `effect: {type:"shadow", shadowType:"inner", ...}` é gravado silenciosamente como `"outer"` — sem erro, sem aviso. Grave se usado para simular "fio de luz interior"/glass: o resultado é um HALO EXTERIOR colorido, exactamente o "AI slop" que as guardrails anti-slop proíbem | O Pencil não suporta inner shadow real neste momento; a propriedade é aceite no schema mas convertida ao gravar | **Nunca usar `effect` do tipo `shadow` para acabamento "interior".** Usar `stroke` com `strokeAlignment:"inner"` em vez disso — para um "fio de luz" (glass/highlight): `stroke: {type:"gradient", gradientType:"linear", rotation:180, size:{height:1}, colors:[{color:"$border-highlight",position:0},{color:"$border-subtle",position:1}]}, strokeWidth:"$border-width-hairline", strokeAlignment:"inner"` (receita validada em produção). Para uma sombra de profundidade lisa (ex. estado "pressed"): `stroke:"$token-de-sombra"` sólido, mesmo `strokeAlignment:"inner"`. **Numa auditoria (Passo 1) desta skill, uma query `Get`+visitor a contar `effect.shadowType==="outer"` cuja `color` referencie tokens de highlight/inset com contagem >0 é sempre uma regressão a corrigir no Passo 4, mesmo que o item de checklist correspondente esteja `✅`** |

## Passo 9 — Cobertura oportunista fora do baseline (não bloqueante)

Igual ao Passo 9 de `pen-create-design`: se a auditoria revelar padrões que
mapeiam a Website / Web App / Mobile / Flows, ler o ficheiro correspondente em
`~/brain/raw/checklist-design/<categoria>/<slug>.md` (já cacheado) e registar
como gaps opcionais para invocação futura — nunca expandir o âmbito obrigatório
da corrida actual.
