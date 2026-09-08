# Dependências do DarkSide

Este projeto usa uma base mínima de dependências para RedM. As dependências de terceiros são mantidas separadas dos resources `ds_*` para facilitar atualização, auditoria e substituição futura.

## Dependências selecionadas

| Resource | Origem | Função | Destino |
|---|---|---|---|
| `ox_lib` | `overextended/ox_lib` | biblioteca utilitária | `resources/[standalone]/ox_lib` |
| `oxmysql` | `overextended/oxmysql` | acesso ao MariaDB/MySQL | `resources/[standalone]/oxmysql` |
| `pma-voice` | `AvarianKnight/pma-voice` | voz de proximidade/Mumble com suporte a RedM | `resources/[voice]/pma-voice` |
| `rsg-core` | `Rexshack-RedM/rsg-core` | infraestrutura de player/core RedM | `resources/[rsg]/rsg-core` |
| `rsg-menubase` | `Rexshack-RedM/rsg-menubase` | dependência do sistema de aparência | `resources/[rsg]/rsg-menubase` |
| `rsg-inventory` | `Rexshack-RedM/rsg-inventory` | inventário compatível com RedM/RSG | `resources/[rsg]/rsg-inventory` |
| `rsg-appearance` | `Rexshack-RedM/rsg-appearance` | aparência/customização do personagem | `resources/[rsg]/rsg-appearance` |

## pma-voice e BaseReborn

A BaseReborn (`Reborn-Studios/BaseReborn`) foi usada como referência porque já utiliza `pma-voice`, inclusive com modos de proximidade e integrações de HUD/rádio.

A cópia existente dentro da BaseReborn declara `game "gta5"` no `fxmanifest.lua`, portanto não foi copiada diretamente para o DarkSide. Em vez disso, o instalador usa o upstream oficial atual `AvarianKnight/pma-voice`, que pertence à mesma família PMA e possui suporte explícito a FiveM/RedM.

O commit inicialmente fixado é:

```text
6c9d96ed7a02e30912f1a0ce92629bf9afbbca8c
```

A licença upstream é MIT e deve permanecer junto ao resource instalado.

A integração DarkSide fica em:

```text
resources/[darkside]/ds_voice
```

Esse adapter expõe o estado de voz aos demais sistemas DarkSide sem fazer `ds_horror`, HUD ou entidades dependerem diretamente da implementação interna do PMA.

## Por que não `ox_inventory`?

O `ox_inventory` oficial declara `game 'gta5'` no `fxmanifest.lua`. Por isso ele não entra na fundação do DarkSide em RedM. Para o protótipo usamos `rsg-inventory`, cujo manifest declara `game 'rdr3'` e já utiliza `ox_lib` e `oxmysql`.

Mais tarde poderemos substituir a interface e regras do `rsg-inventory` por `ds_inventory` sem trocar a camada de persistência inteira.

## Instalação no Windows

Na raiz do projeto:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install-dependencies.ps1
```

Para reinstalar todas as dependências:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install-dependencies.ps1 -Force
```

Depois valide:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-dependencies.ps1
```

## Versões de runtime fixadas inicialmente

As dependências Overextended são baixadas dos artefatos de release já compilados:

- `ox_lib` v3.39.0
- `oxmysql` v2.14.1

O `pma-voice` é fixado em commit conhecido com suporte a RedM. Os resources RSG são clonados do branch `main` e têm o repositório `.git` interno removido para que possam ser usados como dependências locais do projeto.

## Configuração inicial do pma-voice

O `server.cfg.example` ativa áudio nativo e restringe o envio à distância de voz:

```cfg
setr voice_useNativeAudio true
setr voice_useSendingRangeOnly true
setr voice_enableUi 1
setr voice_enableProximityCycle 1
setr voice_defaultVoiceMode 2
setr voice_enableSubmix 1
```

Telefone, rádio e animação de rádio começam desligados porque ainda não fazem parte do gameplay DarkSide:

```cfg
setr voice_enableRadios 0
setr voice_enableCalls 0
setr voice_enableRadioAnim 0
```

## Ordem de inicialização

```text
oxmysql
ox_lib
pma-voice
rsg-core
rsg-menubase
rsg-inventory
rsg-appearance

ds_core
ds_clans
ds_powers
ds_voice
ds_ai
ds_killers
ds_horror
```

Novos resources DarkSide entram depois das dependências que realmente utilizarem.

## Licenças

Cada projeto de terceiro mantém seus próprios arquivos `LICENSE`, `NOTICE` e atribuições. Não remova esses arquivos ao versionar ou distribuir as dependências.
