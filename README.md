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
- pma-voice / Mumble
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
resources/[voice]/pma-voice
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

> A BaseReborn foi usada como referência para PMA, mas a cópia incluída nela declara `game "gta5"`. O instalador usa o upstream atual `AvarianKnight/pma-voice`, que possui suporte explícito a RedM.

Veja também `DEPENDENCIES.md` e `docs/VOICE.md`.

## Arquitetura

```text
RedM
├── pma-voice
└── RSG-Core
    └── DarkSide Framework
        ├── ds_core
        ├── ds_clans
        ├── ds_powers
        ├── ds_voice
        ├── ds_inventory
        ├── ds_progression
        ├── ds_zones
        ├── ds_ai
        ├── ds_killers
        ├── ds_horror
        ├── ds_entities
        ├── ds_director
        ├── ds_events
        ├── ds_hud
        ├── ds_audio
        └── ds_admin
```

O RSG-Core é infraestrutura. As regras de gameplay pertencem aos resources `ds_*`. O `ds_voice` serve como adapter entre o PMA e os sistemas DarkSide.

## Recursos já implementados

- `ds_core`: integração base com RSG-Core e persistência DarkSide.
- `ds_clans`: estrutura inicial de clãs jogáveis.
- `ds_powers`: energia, cooldown e poderes iniciais.
- `ds_voice`: adapter do pma-voice, leitura de modo/distância e estado de fala para HUD, IA e sistemas de terror.
- `ds_ai`: controlador reutilizável de NPCs com visão, audição e estados `IDLE`, `INVESTIGATE`, `CHASE`, `ATTACK` e `SEARCH`.
- `ds_killers`: spawn networked, registry server-side, comandos administrativos e persistência de encontros.
- `ds_horror`: zonas de horror, intensidade progressiva, efeitos nativos de atmosfera, modo de teste e telemetria SQL.

O primeiro killer técnico é `hunter` / **The Hunter**. O modelo atual é temporário; serve para validar IA e networking.

## Voz

O `server.cfg.example` inicia `pma-voice` com áudio nativo e `voice_useSendingRangeOnly` habilitados. Telefone, rádio e animação de rádio começam desligados até existir gameplay para eles.

A tecla padrão de troca de proximidade é `HOME`, seguindo a referência usada na BaseReborn.

A camada `ds_voice` expõe:

```lua
exports['ds_voice']:GetState()
exports['ds_voice']:GetMode()
exports['ds_voice']:IsTalking()
```

Veja `docs/VOICE.md`.

## Banco de dados

Instalação nova:

```text
database/schema.sql
```

Se você já importou schemas anteriores, execute as migrations em ordem:

```text
database/migrations/002_killers.sql
database/migrations/003_horror.sql
```

Tabelas DarkSide adicionadas nesta etapa:

```text
ds_killer_instances
ds_killer_encounters
ds_horror_events
ds_horror_zone_state
```

A voz em tempo real não necessita de tabela SQL nesta fase.

## Teste do killer

Com a ACE `darkside.admin` configurada:

```text
/dskiller spawn hunter
/dskiller list
/dskiller delete <instance_id>
/dskiller clear
```

O killer já pode investigar ruídos. Tiros possuem alcance de audição maior; movimento próximo também pode levá-lo ao estado `INVESTIGATE` mesmo sem linha de visão.

## Teste do sistema de horror

Na sua posição atual:

```text
/dshorror test
```

Ou escolha a duração em segundos:

```text
/dshorror test 300
```

Para encerrar:

```text
/dshorror stop
```

A zona temporária aumenta a intensidade com o tempo e dispara efeitos de câmera, som nativo e pós-processamento. Ela existe apenas para validar a infraestrutura; as zonas definitivas serão definidas depois da escolha das regiões do mapa.

## Pesquisa FiveM -> RedM

A pesquisa de resources de horror do ecossistema FiveM está registrada em `docs/HORROR_RESEARCH.md`. Recursos GTA V pagos, escrow, peds com propriedade intelectual ou downloads sem permissão de redistribuição não são copiados para este repositório. As ideias úteis são reimplementadas para RedM dentro da arquitetura DarkSide.

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
10. Killer ouvir/investigar, perseguir, atacar, perder alvo e procurar novamente.
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

**Fase 0 — Fundação técnica / Vertical Slice.**

A fundação, clãs, poderes, voz PMA/RedM, primeiro killer, percepção por som e primeira camada de horror já estão no repositório. Próximas prioridades: áudio 3D próprio, entidades/aparições, zonas permanentes, Horror Director e progressão.

Consulte `docs/GDD.md`, `docs/ARCHITECTURE.md`, `docs/ROADMAP.md`, `docs/KILLERS.md`, `docs/HORROR_RESEARCH.md` e `docs/VOICE.md`.
