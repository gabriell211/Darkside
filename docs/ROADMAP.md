# DarkSide — Roadmap

## Fase 0 — Fundação técnica

Status: **em andamento**

- [x] Estrutura RedM + RSG-Core
- [x] ox_lib / oxmysql
- [x] rsg-inventory / rsg-appearance / rsg-menubase
- [x] `ds_core`
- [x] Persistência inicial de personagem
- [x] `ds_clans`
- [x] DarkSide e Anjos Caídos
- [x] `ds_powers`
- [x] Energia e cooldown server-side
- [x] `ds_ai`
- [x] State machine inicial de NPC
- [x] `ds_killers`
- [x] Primeiro killer técnico (`hunter`)
- [x] SQL de instâncias e encontros
- [ ] Teste real com dois clients RedM
- [ ] Handoff de network ownership para IA
- [ ] Recuperação de killer após disconnect do owner

## Fase 1 — Vertical Slice jogável

- [ ] `ds_zones`
- [ ] Região de teste com regras próprias
- [ ] Spawn seguro de killers por pontos/zonas
- [ ] Percepção por som/tiros
- [ ] Percepção por luz
- [ ] Loot inicial
- [ ] Integração real com inventário
- [ ] Morte / estado caído / revive DarkSide
- [ ] HUD mínima
- [ ] Um poder funcional e visual por clã
- [ ] Um encontro completo: explorar -> detectar -> perseguir -> fugir/lutar -> recompensa

## Fase 2 — Horror sistêmico

- [ ] `ds_entities`
- [ ] Criaturas sombrias
- [ ] Entidades não convencionais
- [ ] Arquétipos de IA por tipo de ser
- [ ] Stalking e emboscada
- [ ] Audição avançada
- [ ] Memória de alvo
- [ ] Population manager
- [ ] Spawn/despawn por distância e região
- [ ] `ds_director`
- [ ] Terror Director baseado em tensão, grupo, vida, recursos e tempo desde último encontro
- [ ] Áudio e clima reativos

## Fase 3 — Progressão e mundo persistente

- [ ] `ds_progression`
- [ ] Árvore de poderes
- [ ] Rank de clã
- [ ] Reputação
- [ ] Territórios
- [ ] Relíquias
- [ ] Missões de clã
- [ ] Descobertas/lore
- [ ] Bosses por fases
- [ ] Estado global persistente

## Fase 4 — Multiplayer em escala

- [ ] PvP por regras/zonas
- [ ] Party
- [ ] Guerra de clãs
- [ ] Eventos globais
- [ ] Balanceamento para 10/25/50+ players
- [ ] Telemetria
- [ ] Analytics de mortes/encontros
- [ ] Otimização de IA e entidades

## Fase 5 — Operação

- [ ] `ds_admin`
- [ ] Logs e auditoria completos
- [ ] Anticheat focado nos eventos DarkSide
- [ ] Rate limits
- [ ] Backups automáticos
- [ ] DEV / TEST / PROD
- [ ] Pipeline de release
- [ ] Versionamento e changelog

## Regra de prioridade

Nenhuma camada grande de economia, crafting ou conteúdo secundário deve entrar antes do Vertical Slice provar que o loop central é divertido. A prioridade é sempre:

```text
clã -> exploração -> tensão -> NPC sobrenatural -> perseguição/combate -> consequência -> progressão
```
