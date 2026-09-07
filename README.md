# DarkSide

DarkSide é um projeto de jogo sobrenatural multiplayer construído sobre RedM. O Red Dead Redemption 2 é usado como plataforma técnica e mundo-base; o objetivo é que a experiência final tenha identidade própria e não pareça um servidor RP western tradicional.

## Regras do universo já definidas

- Não existem humanos jogáveis.
- Não existem demônios.
- Os jogadores pertencem a clãs sobrenaturais.
- **DarkSide** é um clã jogável e mantém o conceito central **“Uma Cidade, Dois Mundos”**.
- **Anjos Caídos** é um clã jogável; continuam sendo anjos, não demônios.
- Killers, criaturas sombrias, entidades e bosses são NPCs controlados pelo jogo.
- Clãs, poderes, progressão, PvE e conflito territorial formam a camada de gameplay dos jogadores.
- Terror, exploração e mundo vivo têm prioridade sobre economia de RP tradicional.

## Stack inicial

- RedM / FXServer
- RSG-Core
- RSG Inventory
- RSG Appearance
- RSG Menubase
- ox_lib
- oxmysql
- MariaDB/MySQL
- Lua
- NUI (HTML/CSS/JavaScript) quando necessário

## Instalação das dependências

No Windows, depois de clonar o repositório, rode na raiz:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install-dependencies.ps1
```

O instalador coloca automaticamente:

```text
resources/[standalone]/ox_lib
resources/[standalone]/oxmysql
resources/[rsg]/rsg-core
resources/[rsg]/rsg-menubase
resources/[rsg]/rsg-inventory
resources/[rsg]/rsg-appearance
```

Validação:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-dependencies.ps1
```

> `ox_inventory` não é usado porque o resource oficial é declarado para `gta5`. No RedM, a base inicial usa `rsg-inventory`.

Veja também `DEPENDENCIES.md`.

## Arquitetura

```text
RedM
└── RSG-Core
    └── DarkSide Framework
        ├── ds_core
        ├── ds_clans
        ├── ds_powers
        ├── ds_inventory
        ├── ds_progression
        ├── ds_zones
        ├── ds_ai
        ├── ds_killers
        ├── ds_entities
        ├── ds_director
        ├── ds_events
        ├── ds_hud
        ├── ds_audio
        └── ds_admin
```

O RSG-Core é infraestrutura. As regras de gameplay pertencem aos resources `ds_*`.

## Primeira meta: Vertical Slice

A primeira versão jogável deve provar o conceito inteiro com o menor escopo possível:

1. Conectar ao servidor.
2. Carregar/criar personagem.
3. Escolher entre DarkSide e Anjos Caídos.
4. Spawnar em uma região de teste.
5. Exibir HUD mínima.
6. Ter inventário e equipamento básico.
7. Usar pelo menos um poder por clã.
8. Explorar e coletar loot.
9. Encontrar um killer NPC.
10. Killer investigar, perseguir, atacar, perder alvo e procurar novamente.
11. Morrer/reviver sem lógica de hospital humano.
12. Persistir clã e progressão no banco.

## Princípios técnicos

- Servidor é autoridade para clã, progressão, item, recompensa e estados importantes.
- Configurações de gameplay devem ser data-driven e não hardcoded em vários arquivos.
- Recursos devem ser modulares e com responsabilidades claras.
- NPCs distantes devem ser desativados/despawnados para preservar performance.
- Nada de depender de dezenas de scripts de empregos/economia de RP que não pertencem ao jogo.
- Toda feature nova deve respeitar o GDD e a arquitetura do projeto.

## Status

**Fase 0 — Fundação técnica.**

A estrutura inicial do projeto está sendo criada agora. Consulte `docs/GDD.md`, `docs/ARCHITECTURE.md` e `docs/ROADMAP.md`.
