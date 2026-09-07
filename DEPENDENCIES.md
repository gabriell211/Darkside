# Dependências do DarkSide

Este projeto usa uma base mínima de dependências para RedM. As dependências de terceiros são mantidas separadas dos resources `ds_*` para facilitar atualização, auditoria e substituição futura.

## Dependências selecionadas

| Resource | Origem | Função | Destino |
|---|---|---|---|
| `ox_lib` | `overextended/ox_lib` | biblioteca utilitária | `resources/[standalone]/ox_lib` |
| `oxmysql` | `overextended/oxmysql` | acesso ao MariaDB/MySQL | `resources/[standalone]/oxmysql` |
| `rsg-core` | `Rexshack-RedM/rsg-core` | infraestrutura de player/core RedM | `resources/[rsg]/rsg-core` |
| `rsg-menubase` | `Rexshack-RedM/rsg-menubase` | dependência do sistema de aparência | `resources/[rsg]/rsg-menubase` |
| `rsg-inventory` | `Rexshack-RedM/rsg-inventory` | inventário compatível com RedM/RSG | `resources/[rsg]/rsg-inventory` |
| `rsg-appearance` | `Rexshack-RedM/rsg-appearance` | aparência/customização do personagem | `resources/[rsg]/rsg-appearance` |

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

As duas dependências Overextended são baixadas dos artefatos de release já compilados:

- `ox_lib` v3.39.0
- `oxmysql` v2.14.1

Os resources RSG são clonados do branch `main` e têm o repositório `.git` interno removido para que possam ser versionados junto da cópia de desenvolvimento do DarkSide.

## Ordem de inicialização

```text
oxmysql
ox_lib
rsg-core
rsg-menubase
rsg-inventory
rsg-appearance

ds_core
ds_clans
ds_powers
```

Novos resources DarkSide entram depois das dependências que realmente utilizarem.

## Licenças

Cada projeto de terceiro mantém seus próprios arquivos `LICENSE`, `NOTICE` e atribuições. Não remova esses arquivos ao versionar ou distribuir as dependências.
