---
source:
  - https://www.semrush.com/blog/technical-seo-checklist/
  - https://www.semrush.com/blog/on-page-seo-checklist/
  - https://www.semrush.com/blog/ai-search-optimization/
category: ai-search-geo
captured: 2026-09-27
---

# Acesso de bots de IA ao conteúdo (pré-requisito de tudo o resto)

Sem isto, nada do resto desta pasta importa: se o bot não consegue aceder, não há
conteúdo para citar.

## Checklist

- **Auditar o `robots.txt` separadamente para bots de IA** — por omissão a maioria dos
  bots segue as directivas existentes, por isso um `Disallow` genérico pode cortar
  silenciosamente o acesso a respostas de IA mesmo sem intenção de bloquear IA. Bots a
  procurar (lista consolidada das fontes): **GPTBot, ChatGPT-User, OAI-SearchBot**
  (OpenAI), **CCBot** (Common Crawl), **ClaudeBot, Claude-User, Claude-SearchBot,
  Claude-Web** (Anthropic), **PerplexityBot** (Perplexity).
- **Distinguir bots de recolha (retrieval) de bots de treino (training)** — os de
  recolha alimentam respostas em tempo real (bloqueá-los tira-nos de respostas de IA
  imediatas); os de treino só alimentam modelos futuros. Podem e devem ser controlados
  separadamente no `robots.txt`.
- **Testar visibilidade directamente**: pesquisar o nome da marca/tópicos-chave no
  ChatGPT, Perplexity e Claude; nunca aparecer como fonte é sinal de um problema de
  acesso, não só de conteúdo.
- **Remover barreiras ao rastreio**: login walls/paywalls, navegação só-JavaScript, erros
  de servidor, páginas lentas nas páginas importantes.
- **Confirmar canonical tags correctas** — não bloqueiam bots de IA, mas podem levar à
  citação da versão errada da página ou a ser ignorada como duplicado.
- **(E-commerce) Testar o checkout com um agente de compras de IA** (ex. o assistente de
  compras do ChatGPT) para ver se encalha, não encontra campos ou não avança — uma falha
  aí afecta provavelmente outros agentes também.
- **(E-commerce) Manter páginas de políticas (devoluções, envios, FAQ) em HTML simples**
  para agentes conseguirem ler sem barreira técnica/de renderização.
- **(E-commerce) Construir campos, botões e passos de checkout com elementos HTML
  standard**, não widgets custom que agentes podem não reconhecer.
- **(E-commerce) Confirmar que páginas críticas funcionam sem JavaScript** — alguns
  agentes não executam scripts e vêem página em branco.
- **(E-commerce) Garantir que banners de cookies/modais de login se fecham com um botão
  HTML standard, claramente rotulado.**
- **(E-commerce) Evitar checkouts que só actualizam visualmente** — se o estado muda
  depois de uma acção, garantir que a informação actualizada fica reflectida no HTML
  subjacente, não só no ecrã: agentes lêem o HTML/DOM, não a renderização visual.

## Fontes

- Semrush — "The technical SEO checklist for search engines and AI search" (2026-06-23).
- Semrush — "On-page SEO checklist" (2026-04-23), item 12.
- Semrush — "How to optimize for AI search results in 2026" (Carlos Silva, 2026-05-06).
