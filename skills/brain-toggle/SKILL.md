---
name: brain-toggle
description: Liga, desliga ou mostra o estado do second brain pessoal em ~/brain. Usa quando o utilizador disser "liga o brain", "desliga o brain", "brain on", "brain off", "brain status", "estado do brain", ou quiser controlar se o agente lê ~/brain. Suporta modo soft (só muda STATUS em LOADER.md) e modo hard (remove/repõe o import de ~/brain/LOADER.md nos ficheiros CLAUDE.md/AGENTS.md globais, garantindo que o brain nem entra em contexto).
---

# brain-toggle

Controla o interruptor do second brain pessoal em `~/brain`.

## Modos

- **soft** (default): só troca a 1ª linha de `~/brain/LOADER.md` entre `STATUS: ON` e `STATUS: OFF`. Os ficheiros ponteiro (`~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, `~/AGENTS.md`) continuam a importar `~/brain/LOADER.md` — um agente que ignore a regra "se OFF, ignora tudo" ainda tecnicamente lê a 1ª linha.
- **hard**: além do soft, remove o bloco `<!-- BRAIN:START --> ... <!-- BRAIN:END -->` (que contém `@~/brain/LOADER.md`) dos três ficheiros ponteiro. Sem esse import, `~/brain` não entra em contexto de todo. `on --hard` repõe o bloco.

## Como executar

Corre o script bash em `scripts/toggle.sh`, relativo a esta skill (`~/brain/skills/brain-toggle/scripts/toggle.sh`):

```bash
~/brain/skills/brain-toggle/scripts/toggle.sh on            # soft on
~/brain/skills/brain-toggle/scripts/toggle.sh off           # soft off
~/brain/skills/brain-toggle/scripts/toggle.sh on --hard     # hard on (repõe import nos 3 ponteiros)
~/brain/skills/brain-toggle/scripts/toggle.sh off --hard    # hard off (remove import dos 3 ponteiros)
~/brain/skills/brain-toggle/scripts/toggle.sh status        # mostra STATUS + estado hard de cada ponteiro
```

Depois de correr, mostra ao utilizador o output do `status` (o próprio script já o imprime no fim de `on`/`off`) para confirmar o novo estado.
