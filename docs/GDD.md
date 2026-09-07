# DarkSide — Game Design Document

## 1. Visão

DarkSide é um jogo sobrenatural multiplayer persistente sobre RedM. O mundo é dividido entre clãs jogáveis sobrenaturais; ameaças como killers, criaturas sombrias, entidades e bosses são NPCs.

O objetivo é criar uma experiência própria, com foco em terror, exploração, progressão, poderes, territórios e eventos dinâmicos.

## 2. Regras fixas do universo

- Não existem humanos.
- Não existem demônios.
- DarkSide é um clã jogável.
- Anjos Caídos é um clã jogável.
- Anjos Caídos continuam sendo anjos, não demônios.
- Killers, criaturas, entidades e bosses são NPCs.
- O conceito da DarkSide é “Uma Cidade, Dois Mundos”.

## 3. Pilares de gameplay

### Terror
O jogador pode ser poderoso, mas nunca deve se sentir invencível.

### Exploração
O mundo recompensa descoberta de áreas, relíquias, eventos, segredos e lore.

### Clãs
A escolha do clã altera identidade, progressão, poderes e relações com o mundo.

### Progressão
A progressão é baseada em desbloqueios e especialização, não em inflação exagerada de atributos.

### Mundo vivo
Eventos devem acontecer sem depender de administradores.

## 4. Clãs

Todo clã deve possuir:

- origem;
- lore;
- símbolo;
- aparência;
- território;
- ranks;
- poderes;
- fraquezas;
- relíquias;
- missões;
- progressão;
- relações com outros clãs e entidades.

### 4.1 DarkSide

Conceito central: **Uma Cidade, Dois Mundos**.

A origem biológica/metafísica da DarkSide ainda não está fechada e não deve ser inventada no código antes da decisão de lore.

### 4.2 Anjos Caídos

Seres celestiais exilados ou separados de sua antiga ordem. Não são demônios.

Possíveis elementos de gameplay, sujeitos a validação:

- asas;
- energia celestial;
- relíquias;
- marcas;
- hierarquia;
- poderes e limitações próprias.

## 5. Loop principal

```text
Entrar
  ↓
Carregar personagem
  ↓
Escolher/continuar clã
  ↓
Explorar região
  ↓
Coletar recursos / descobrir lore / completar objetivo
  ↓
Encontrar evento, criatura, entidade ou killer
  ↓
Combater, fugir, investigar ou sobreviver
  ↓
Receber progressão/recompensa
  ↓
Retornar ao território / preparar próxima saída
```

## 6. Personagem

Dados mínimos:

- characterId
- name
- clanId
- clanRank
- level
- xp
- appearance
- powers
- energy
- reputation
- inventory
- equipment
- discoveries
- storyProgress
- statistics

## 7. Poderes

Categorias previstas:

- mobilidade;
- ofensivo;
- defensivo;
- controle;
- sensorial;
- passivo;
- ultimate.

Todo poder deve ser configurável por dados:

```lua
{
    id = 'shadow_step',
    clan = 'darkside',
    category = 'mobility',
    energyCost = 25,
    cooldown = 12,
    range = 15,
    duration = 2,
    animation = nil,
    effect = nil,
    sound = nil,
}
```

## 8. NPCs

Categorias principais:

- ambiental;
- criatura;
- killer;
- entidade;
- boss.

### Killer
Foco em perseguição, rastreamento e pressão.

### Criatura
Comportamento territorial, predatório ou monstruoso.

### Entidade
Pode interferir em som, visão, iluminação, clima e percepção.

### Boss
Deve possuir mecânicas/fases; nunca ser apenas um NPC comum com muita vida.

## 9. IA

Estados base:

```text
IDLE
PATROL
INVESTIGATE
STALK
CHASE
ATTACK
SEARCH
RETREAT
ENRAGED
```

Percepção pode considerar:

- visão;
- ruído;
- tiros;
- movimento;
- luz;
- distância;
- poder utilizado;
- território;
- clã;
- contexto do evento.

## 10. Horror Director

O `ds_director` monitora a sessão e cria tensão dinamicamente.

Entradas possíveis:

- quantidade de jogadores na área;
- saúde média;
- energia;
- tempo desde último encontro;
- região;
- horário;
- ameaça ativa;
- histórico recente de eventos.

Saídas possíveis:

- áudio;
- neblina;
- mudança de clima;
- sinais ambientais;
- spawn indireto de ameaça;
- evento regional;
- bloqueio temporário;
- encontro com killer/entidade.

## 11. Regiões

O mapa original do RDR2 será reinterpretado para a identidade DarkSide.

Cada região define:

- nome próprio;
- perigo;
- clima;
- tabela de NPCs;
- killers elegíveis;
- eventos;
- loot;
- boss;
- segredos;
- afinidade com clãs.

## 12. PvP e territórios

PvP não deve transformar o jogo em deathmatch.

Tipos de zona:

- segura;
- PvE;
- disputada;
- PvP;
- território de clã;
- evento de guerra.

Territórios podem depender de objetivos, relíquias, defesa ou eventos, evitando captura por simples permanência em círculo.

## 13. Loot e inventário

Categorias:

- consumíveis;
- armas;
- relíquias;
- artefatos;
- chaves;
- materiais;
- itens de missão;
- itens de clã.

Raridades previstas:

- comum;
- incomum;
- raro;
- relíquia;
- amaldiçoado;
- lendário.

## 14. Progressão

Três camadas:

### Personagem
- nível;
- poderes;
- equipamento;
- descobertas.

### Clã
- rank;
- reputação;
- acesso;
- relíquias;
- território.

### Mundo
- regiões descobertas;
- bosses;
- eventos globais;
- estado narrativo.

## 15. Morte

Não existe hospital humano.

O sistema final ainda será definido, mas deve suportar:

- estado caído;
- revive por aliado;
- checkpoint;
- penalidade controlada;
- efeitos sobrenaturais de morte.

## 16. UI/HUD

Minimalista. Exibir somente o necessário.

Exemplo:

```text
VIDA
ENERGIA
PODER ATIVO
MUNIÇÃO (quando aplicável)
```

## 17. Áudio

Áudio é parte central do terror:

- ambiente;
- passos;
- respiração;
- sussurros;
- sinais de ameaça;
- música dinâmica;
- silêncio intencional.

## 18. Vertical Slice

A primeira versão deve conter:

- DarkSide;
- Anjos Caídos;
- 1 região;
- 1 poder funcional por clã;
- inventário mínimo;
- loot mínimo;
- 1 killer;
- IA com investigar/perseguir/atacar/procurar;
- HUD mínima;
- morte/revive;
- persistência básica.

O vertical slice só é aprovado se for divertido e transmitir a identidade proposta.
