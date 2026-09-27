---
source: https://www.semrush.com/blog/technical-seo-checklist/
category: technical
captured: 2026-09-27
---

# Crawling e indexação

Garantir que os motores de busca (e os motores de resposta por IA, que partilham em
grande parte o mesmo índice) conseguem encontrar, rastrear e indexar as páginas certas.

## Checklist

- **Confirmar indexação real por motor**: verificar o relatório "Pages" do Google Search
  Console e, separadamente, o "Site Explorer" do Bing Webmaster Tools — não assumir que o
  índice do Bing corresponde ao da Google.
- **Investigar "Crawled – currently not indexed"**: a página foi vista mas considerada de
  baixo valor ou demasiado semelhante a outra já indexada; priorizar reescrever/actualizar
  as mais importantes.
- **Confirmar que não há `Blocked by robots.txt` acidental** em páginas que se quer
  indexadas.
- **Confirmar que não há `noindex` acidental** em páginas importantes.
- **Considerar submissão via IndexNow** para indexação mais rápida no Bing e motores que o
  suportem.
- **Verificar variantes de URL** (http/https, www/sem-www) — motores de busca tratam cada
  uma como um site tecnicamente distinto, o que pode dividir autoridade/duplicar conteúdo.
- **Escolher uma versão canónica** (HTTPS, com ou sem www) e fazer redirect 301 de todas
  as outras variantes para essa.
- **Auditar `Disallow` no robots.txt** para confirmar que nenhuma pasta/página importante
  está bloqueada por engano.
- **Encontrar e corrigir cadeias de redirect** (A → B → C) **e loops** (A → B → A) — ambos
  desperdiçam crawl budget, atrasam a página para o utilizador e diluem a autoridade
  passada entre páginas. Corrigir apontando directamente para o destino final; quebrar
  loops.
- **Encontrar e corrigir links internos quebrados** — repor a página apagada se possível,
  ou redirect 301 para um substituto relevante.
- **Encontrar e corrigir links externos quebrados** — substituir por uma versão
  actualizada do recurso, remover o link, ou trocar por outra fonte.
- **Encontrar e corrigir erros de servidor (5xx)** — bloqueiam por completo o rastreio e
  indexação do conteúdo.

## Fonte

Semrush — "The technical SEO checklist for search engines and AI search" (Tushar Pol,
2026-06-23).
