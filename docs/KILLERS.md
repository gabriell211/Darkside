# DarkSide — Killer NPC Prototype

## Objetivo

`ds_ai` é a camada genérica de IA. `ds_killers` define e gerencia killers usando essa camada. O killer não é um player: é um NPC de mundo controlado pelo sistema.

## Estados de IA atuais

```text
IDLE
  -> CHASE
  -> ATTACK
  -> SEARCH
  -> IDLE
```

- **IDLE**: procura o jogador visível mais próximo dentro do alcance.
- **CHASE**: usa `TaskCombatPed` e acompanha o alvo.
- **ATTACK**: estado de proximidade; o ped continua no combate nativo.
- **SEARCH**: vai para a última posição conhecida e procura novamente por alguns segundos.

A camada já guarda a última posição vista, tempo sem linha de visão, distância de perda e alcance de ataque. A evolução planejada inclui audição, tiros, luz, rastros, cheiro/sangue, patrulha, stalking, emboscadas e comportamentos específicos por killer.

## Killer disponível

`hunter` / **The Hunter** é o killer técnico inicial. O modelo atual é temporário e usa um ped nativo do RDR2; aparência final virá depois.

Configuração: `resources/[darkside]/ds_killers/shared/config.lua`.

## Teste no servidor

Importe primeiro `database/schema.sql` e garanta que `ds_ai` e `ds_killers` estejam iniciados após `ds_core`.

Conceda a ACE `darkside.admin` ao grupo/identificador que fará os testes.

Comandos:

```text
/dskiller spawn hunter
/dskiller list
/dskiller delete <instance_id>
/dskiller clear
```

Pelo console, informe o player alvo:

```text
dskiller spawn hunter <playerId>
```

O killer nasce alguns metros à frente do player responsável pela instância e começa em `IDLE`. Ao enxergar um player, inicia perseguição.

## Banco

`ds_killer_instances` armazena o ciclo de vida das instâncias.

`ds_killer_encounters` é append-only e registra transições importantes (`SPAWNED`, `CHASE`, `ATTACK`, `SEARCH`, `IDLE`, `KILLER_DIED`, falhas). Esses dados serão úteis para balanceamento e para o futuro Horror Director.

## Segurança

Spawn e remoção são restritos por ACE. O servidor mantém o registry das instâncias e rejeita eventos de estado vindos de um client que não seja o owner daquela instância. O client não escolhe recompensas, progressão ou dados persistidos.

## Limitações desta versão

É um vertical slice técnico, não a IA final. O controlador roda no client que criou o ped networked. Antes de produção será necessário adicionar handoff de ownership, recuperação após disconnect, population manager, spawn points por região e validação de dano/morte no servidor.
