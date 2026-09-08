# Pesquisa de referências de horror (FiveM -> DarkSide/RedM)

Este documento registra recursos de FiveM pesquisados como referência de gameplay. Não copiamos automaticamente arquivos GTA V para RedM: formatos de peds/maps/natives podem ser incompatíveis e vários downloads possuem licenças ou propriedade intelectual que impedem redistribuição.

## O que foi aproveitado agora

### Muhaddil Horror (MIT)
Fonte: https://github.com/Muhaddil/muhaddil_horror

Ideias úteis:
- zonas de horror;
- intensidade progressiva pelo tempo dentro da região;
- efeitos randômicos com probabilidades/cooldowns;
- distorção visual;
- áudio/whispers;
- aparições;
- eventos globais;
- métricas/admin.

Aplicação DarkSide: `ds_horror` foi implementado de forma própria para RedM, começando com zonas, intensidade, efeitos nativos, telemetria SQL e hooks para futuros `ds_audio`, `ds_entities` e `ds_director`.

### ScaryFree
Fonte: https://forum.cfx.re/t/scaryfree-standalone/5223988

Ideias úteis:
- susto configurável;
- ped temporário;
- duração do ped;
- áudio associado ao evento.

Aplicação DarkSide: manter aparições curtas e configuráveis como uma categoria futura de efeito, sem depender de modelos GTA V.

### Standalone Zombie System
Fonte: https://github.com/WeponzTV/Standalone-Zombie-System

Não usaremos zumbis. O que interessa é a arquitetura de percepção:
- NPC sincronizado;
- reação a barulho;
- zonas seguras;
- otimização de loops;
- comportamento diferente conforme o estímulo.

Aplicação DarkSide: `ds_ai` agora possui percepção por visão e som, com alcance separado para presença, corrida e tiro e estado `INVESTIGATE` antes de perseguir.

### NPC Reacts Player Held Weapon
Fonte: https://forum.cfx.re/t/standalone-npc-reacts-player-held-weapon/5404661

Ideias úteis:
- reação contextual a ameaças;
- panic spread;
- scan apenas quando necessário;
- cooldown por NPC.

Aplicação futura: NPCs ambientais e criaturas poderão alertar outros NPCs próximos, fugir, investigar ou atacar dependendo da facção e do clã do player.

### Waypoint Smoke Monster
Fonte: https://forum.cfx.re/t/free-standalone-waypoint-smoke-monster/5177374

Ideias úteis:
- entidade/efeito de fumaça móvel;
- controle de velocidade;
- uso de partículas para criar um ser sem depender de ped humano;
- custo quase zero quando inativo.

Aplicação futura: entidades DarkSide compostas por partículas/neblina, controladas pela IA, sem precisar de modelagem complexa no primeiro protótipo.

### The Haunted Farm
Fonte: https://forum.cfx.re/t/the-haunted-farm/5373179

Ideias úteis:
- interiores com identidade própria;
- áudio com oclusão entre cômodos;
- storytelling ambiental;
- múltiplas áreas pequenas dentro de um mesmo local de horror.

O MLO é GTA V/FiveM e não será redistribuído no projeto RedM. Usaremos apenas a referência de design.

### The Apocalypse Project
Fonte: https://forum.cfx.re/t/the-apocalypse-project-v1-0-3-updated-07-09-2026/1178682

Ideias úteis:
- dividir conteúdo por região;
- recursos separados por função;
- controle de quantidade de entidades;
- otimização progressiva por zona.

Aplicação DarkSide: mapas/entidades futuras serão divididos por zona para evitar um resource monolítico.

### RS ZombieCore / UC NPC Legacy
Fontes:
- https://forum.cfx.re/t/paid-rs-zombiecore-multiplayer-zombie-outbreak-and-survival-world-enhanced-ready/5421636
- https://forum.cfx.re/t/paid-uc-npc-legacy-persistent-npc-zombie-framework-standalone-beta/5423034

São recursos pagos/escrow e não serão copiados. Conceitos relevantes:
- população compartilhada via OneSync;
- visão + audição;
- NPCs persistentes;
- world builder;
- servidor como autoridade;
- limites de população/streaming.

Esses conceitos entram no roadmap de `ds_ai`, `ds_entities` e `ds_director`.

## Assets/peds de horror encontrados

Existem peds FiveM de personagens conhecidos e criaturas, inclusive modelos baseados em franquias como Dead by Daylight/Silent Hill. Eles não serão adicionados ao repositório automaticamente porque:

1. um ped GTA V não é drop-in para RedM;
2. muitos autores proíbem reupload;
3. vários modelos pertencem a franquias de terceiros;
4. um servidor público/comercial precisaria revisar licença e direitos de cada asset.

Para DarkSide, a prioridade é usar:
- peds/props nativos do RDR2 no protótipo;
- assets originais ou licenciados depois;
- partículas e alterações visuais para entidades que não precisam de um modelo completo.

## Próximas extrações úteis da pesquisa

- `ds_audio`: áudio 3D, whispers, footsteps, heartbeat e occlusion hooks.
- `ds_entities`: aparições, sombras, partículas e entidades não-ped.
- `ds_ai`: panic spread, investigação por som e memória de estímulos.
- `ds_director`: pacing adaptativo, cooldown global e combinação de eventos.
- `ds_bosses`: fases, barra de vida e regras próprias por boss.
- `ds_zones`: zonas permanentes com intensidade e estado persistente no SQL.
