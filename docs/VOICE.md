# DarkSide Voice / pma-voice

## Decisão

A BaseReborn usa `pma-voice` em `server/resources/[ Smartphone ]/pma-voice` e foi a referência pedida para a camada de voz do DarkSide.

A cópia da BaseReborn não é instalada diretamente porque seu `fxmanifest.lua` declara `game "gta5"`. O DarkSide roda em RedM.

Para manter a mesma tecnologia sem carregar uma versão antiga específica de FiveM, usamos o upstream oficial atual:

```text
AvarianKnight/pma-voice
commit: 6c9d96ed7a02e30912f1a0ce92629bf9afbbca8c
```

Esse upstream declara `game 'common'` e possui tratamento específico para `GetGameName() == "redm"`, inclusive wrappers de submix de áudio.

## O que reaproveitamos da ideia BaseReborn

- PMA/Mumble como infraestrutura de voz;
- ciclo de distância de voz;
- evento `pma-voice:setTalkingMode` para integrar HUD/gameplay;
- tecla `HOME` como padrão de troca de proximidade;
- possibilidade de submix/efeitos sobre voz;
- rádio e chamadas ficam disponíveis para uso futuro, mas estão desligados no DarkSide inicial.

## Configuração inicial

`server.cfg.example`:

```cfg
setr voice_useNativeAudio true
setr voice_useSendingRangeOnly true
setr voice_enableUi 1
setr voice_enableProximityCycle 1
setr voice_defaultCycle "HOME"
setr voice_defaultVoiceMode 2
setr voice_enableSubmix 1

setr voice_enableRadios 0
setr voice_enableCalls 0
setr voice_enableRadioAnim 0

ensure pma-voice
ensure ds_voice
```

`voice_useNativeAudio` é importante para a direção futura do horror porque permite áudio espacial/reverb e submix.

## Adapter DarkSide

O resource `ds_voice` evita que outros resources dependam diretamente dos detalhes internos do PMA.

Exports client:

```lua
local state = exports['ds_voice']:GetState()
-- state.mode
-- state.distance
-- state.name
-- state.talking

local mode, distance, name = exports['ds_voice']:GetMode()
local isTalking = exports['ds_voice']:IsTalking()
```

Eventos client:

```lua
AddEventHandler('ds_voice:client:stateChanged', function(state, reason)
    -- atualizar HUD, director, telemetria local etc.
end)

AddEventHandler('ds_voice:client:talkingChanged', function(talking, state)
    -- reagir ao começo/fim da fala
end)
```

## Integrações planejadas

### `ds_hud`
Mostrar de forma discreta o modo de proximidade e estado de fala.

### `ds_ai`
No futuro, fala real do jogador pode gerar estímulo para criaturas/killer. Isso deverá ser validado com cuidado para não permitir spoof simples pelo client.

### `ds_horror`
Entidades podem alterar percepção de voz de maneira controlada: abafamento, distorção, eco ou interferência.

### `ds_audio`
Áudio 3D ambiental continua separado de voz de jogador. O PMA não substitui o sistema de stingers, whispers e sons posicionais do mundo.

## Banco de dados

A voz em tempo real não precisa de tabela SQL nesta fase. Não criamos persistência artificial para proximidade ou estado de microfone.

Caso telemetria de sessões de voz seja necessária no futuro, ela deverá registrar apenas eventos relevantes ao gameplay, não conteúdo de áudio.
