# Pesquisa de referências de horror (FiveM -> DarkSide/RedM)

Este documento registra resources, mapas e peds de FiveM pesquisados como referência de gameplay. Não copiamos automaticamente arquivos GTA V para RedM: formatos de peds/maps/natives podem ser incompatíveis e vários downloads possuem licenças ou propriedade intelectual que impedem redistribuição.

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
- resources separados por função;
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

### Unknown Creature
Fonte: https://www.gta5-mods.com/player/unknown-creature-1-add-on-ped-replace-fivem

É um ped genérico de criatura, com quatro variações de pele e LODs. O próprio autor informa que é FiveM-ready, mas também diz que qualquer edição do modelo exige autorização dele. Portanto **não vamos baixar, converter ou redistribuir no DarkSide sem permissão expressa**. Pode ser um candidato visual caso o autor autorize conversão para RedM.

### Jester custom ped
Fonte: https://www.gta5-mods.com/player/jester-custom-ped

Ped custom FiveM que pode servir como referência para um killer original de aparência teatral/macabra. Antes de usar qualquer arquivo, precisamos verificar licença/termos e compatibilidade de conversão para o esqueleto/formato RedM.

### Halloween Pack
Fonte: https://www.gta5-mods.com/player/halloween-pack

Pacote antigo com peds e armas de horror. Há material vindo de XNALARA, então não é uma boa base para redistribuição automática. Serve apenas como referência de categorias de killer/props.

### The Executioner / personagens de franquias
Existem peds FiveM baseados em personagens conhecidos de Silent Hill, Dead by Daylight, Call of Duty e outras franquias. Não serão colocados no repositório DarkSide porque podem envolver direitos de terceiros, mesmo quando o conversor permite uso em FiveM.

## Mapas de horror encontrados

### Patoche Creepy House
Fonte: https://www.gta5-mods.com/maps/mlo-patoche-creepy-house-fivem-altv-sp

MLO de casa isolada feito para FiveM/GTAV. Não é drop-in no RedM. Referência útil para composição de um local de horror: interior pequeno, iluminação controlada, isolamento e reutilização fora de Halloween.

### Lonehaven Legacy
Fonte: https://www.gta5-mods.com/maps/lonehaven

Cidade isolada/assombrada com foco em exploração, easter eggs e storytelling. O mapa é GTA V, mas o conceito combina muito com o DarkSide: uma região própria que parece ter história e eventos acontecendo sem depender de missão linear.

### Backrooms Project
Fonte: https://www.gta5-mods.com/maps/mlo-backrooms-project-sp-fivem

Não é adequado para importar diretamente, mas é uma boa referência para **dimensões/áreas anômalas**: lugares que não precisam respeitar a geografia normal do mapa e podem ser acessados por evento, ritual, portal ou relíquia.

## Áudio encontrado

Há mods de substituição de gritos/dor para GTA V, mas muitos são feitos como `.awc`/OpenIV, não funcionam corretamente no FiveM e ainda reutilizam áudio de outros jogos. Não serão copiados. Para DarkSide vamos usar `ds_audio` com arquivos próprios/licenciados em `.ogg` e áudio 3D/NUI.

## Regra para importar qualquer coisa externa

Antes de um asset externo entrar em `resources/[assets]` ou semelhante, ele precisa passar pelos quatro checks:

1. **Licença permite uso/redistribuição?**
2. **Autor permite edição/conversão?**
3. **Não depende de propriedade intelectual de outra franquia sem autorização?**
4. **Existe caminho técnico real de GTA V/FiveM para RedM sem quebrar rig/animação/textura?**

Se qualquer resposta for "não" ou estiver indefinida, o asset fica somente como referência.

## Para DarkSide, a prioridade de assets é

- peds/props nativos do RDR2 no protótipo;
- assets originais ou licenciados depois;
- partículas e alterações visuais para entidades que não precisam de um modelo completo;
- contratação/conversão autorizada apenas quando o gameplay já estiver validado.

## Próximas extrações úteis da pesquisa

- `ds_audio`: áudio 3D, whispers, footsteps, heartbeat e occlusion hooks.
- `ds_entities`: aparições, sombras, partículas e entidades não-ped.
- `ds_ai`: panic spread, investigação por som e memória de estímulos.
- `ds_director`: pacing adaptativo, cooldown global e combinação de eventos.
- `ds_bosses`: fases, barra de vida e regras próprias por boss.
- `ds_zones`: zonas permanentes com intensidade e estado persistente no SQL.
