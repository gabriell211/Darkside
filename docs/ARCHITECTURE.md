# DarkSide — Arquitetura Técnica

## Objetivo

Construir uma camada de jogo própria sobre RedM, usando RSG-Core apenas como infraestrutura de player/session e integração com o ecossistema RedM.

## Dependências-base

O RSG-Core atual usa `ox_lib` e `oxmysql` como dependências, e expõe `GetCoreObject()` no client e server. O projeto DarkSide deve aproveitar essa integração em vez de duplicá-la.

## Organização de resources

```text
resources/
├── [standalone]
│   ├── ox_lib
│   └── oxmysql
├── [rsg]
│   ├── rsg-core
│   └── ...
└── [darkside]
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

## Responsabilidades

### ds_core
- estado global DarkSide;
- acesso ao RSG-Core;
- utilitários compartilhados;
- lifecycle do player;
- validações centrais;
- eventos internos estáveis.

### ds_clans
- definição dos clãs;
- associação de personagem;
- ranks;
- permissões;
- afinidades e relações.

### ds_powers
- registro e execução de poderes;
- cooldown;
- energia;
- validação server-side;
- efeitos client-side autorizados.

### ds_inventory
- camada de regras DarkSide sobre o inventário;
- categorias e metadata próprias;
- validações de loot/recompensa.

### ds_progression
- nível/XP;
- desbloqueios;
- progressão por clã;
- progressão de mundo.

### ds_zones
- regiões;
- territórios;
- regras por área;
- ativação/desativação de sistemas por distância.

### ds_ai
- state machine compartilhada;
- percepção;
- utilitários de navegação/target;
- throttling de ticks.

### ds_killers
- definição dos killers;
- comportamento especializado;
- spawn/despawn;
- recompensas.

### ds_entities
- entidades sobrenaturais e criaturas;
- alterações ambientais;
- interações especiais.

### ds_director
- observação de tensão da sessão;
- pacing;
- seleção de eventos;
- regras de cooldown global/regional.

### ds_events
- eventos mundiais e regionais;
- persistência de estado relevante;
- coordenação com director/zones.

### ds_hud
- HUD mínima;
- prompts;
- feedback de energia/poder/ameaça.

### ds_audio
- áudio dinâmico;
- sinais de ameaça;
- hooks para director e entidades.

### ds_admin
- ferramentas de teste/admin;
- spawn controlado;
- inspect de player/NPC;
- logs e debug.

## Autoridade do servidor

O cliente nunca é fonte de verdade para:

- clã;
- rank;
- XP;
- recompensas;
- inventário;
- cooldown final;
- energia final;
- progressão;
- território;
- estado persistente do mundo.

O client pode solicitar ações e reproduzir apresentação, mas o server valida contexto, distância, permissão, custo e cooldown.

## Eventos

Prefira eventos namespaced:

```text
ds:server:*
ds:client:*
ds:internal:*
```

Eventos `internal` são para comunicação entre resources no mesmo lado e não devem ser tratados como API pública sem necessidade.

## Dados configuráveis

Regras de conteúdo devem ficar em arquivos de configuração sempre que possível:

```text
config/
├── clans.lua
├── powers.lua
├── zones.lua
├── killers.lua
├── creatures.lua
├── loot.lua
└── progression.lua
```

## Banco de dados

Tabelas planejadas:

```text
ds_characters
ds_clans
ds_clan_members
ds_player_powers
ds_progression
ds_reputation
ds_discoveries
ds_world_state
ds_events
ds_territories
ds_audit_logs
```

O schema será adicionado apenas quando os campos do vertical slice estiverem fechados.

## Performance

- IA deve usar distância e relevância para reduzir ticks.
- Nenhum resource deve manter loop `Wait(0)` global sem necessidade real.
- NPCs precisam de lifecycle explícito: spawn, active, dormant, despawn.
- Eventos devem limpar entidades e handlers temporários.
- O número de NPCs ativos simultaneamente deve ser controlado por região.

## Desenvolvimento

Fluxo recomendado:

```text
main       -> versão estável
develop    -> integração
feature/*  -> features isoladas
fix/*      -> correções
```

Para o primeiro bootstrap, o projeto pode começar em `main`; quando houver servidor funcional, criar `develop` e passar a integrar por PR.
