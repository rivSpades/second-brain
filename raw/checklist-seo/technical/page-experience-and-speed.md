---
source:
  - https://www.semrush.com/blog/technical-seo-checklist/
  - https://www.semrush.com/blog/on-page-seo-checklist/
category: technical
captured: 2026-09-27
---

# Experiência de página, velocidade e mobile

## Checklist

### Usabilidade mobile
- **Testar manualmente no telemóvel**: texto pequeno demais, alvos de toque demasiado
  próximos, conteúdo mais largo que o viewport (scroll horizontal), pop-ups que bloqueiam
  conteúdo e são difíceis de fechar.
- **Design responsivo** + copy mobile-friendly (frases/parágrafos curtos) + botões/menus
  fáceis de tocar e navegar.
  Rationale: a Google avalia e ordena principalmente pela versão mobile da página, e
  sistemas de IA que se apoiam no índice da Google herdam essa mesma avaliação
  mobile-first — lacunas de UX mobile prejudicam os dois canais.

### Core Web Vitals
- **Alvo**: LCP ≤ 2.5s, INP < 200ms, CLS < 0.1.
- Verificar o relatório de Core Web Vitals no Search Console; passar URLs marcados
  "Poor"/"Needs improvement" pelo PageSpeed Insights para correcções concretas.
- **Remover interstitials intrusivos**: pop-ups full-screen que bloqueiam o conteúdo à
  chegada, overlays com dismissal obrigatório, ou anúncios que empurram o conteúdo
  principal para baixo do fold.
  Nota: avisos de cookies, verificação de idade e logins de paywall **não** são
  penalizados como intrusivos.

### Velocidade
- Remover cadeias de redirect, optimizar imagens/media, eliminar JavaScript
  render-blocking.
  Rationale (pesquisa por IA): se alguém clica numa resposta gerada por IA e a página
  demora a carregar, perde-se a visita que a própria visibilidade em IA já tinha
  conquistado — o tráfego vindo de IA é tão sensível à velocidade como o orgânico.

## Fontes

- Semrush — "The technical SEO checklist for search engines and AI search" (2026-06-23).
- Semrush — "On-page SEO checklist: The complete task list for 2026" (Carlos Silva,
  2026-04-23), itens 13–14.
