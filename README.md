# Ultima Veritas

RPG de ação 2D lateral numa Roma que nunca caiu, onde uma profecia falsa traz um advogado do nosso mundo para o centro de uma conspiração.

> *Ultima veritas*: "a última verdade", em latim.

## Estado atual: greybox

O projeto está na fase de **greybox**: tudo é feito de blocos coloridos, sem arte, para testar se andar, pular e lutar estão gostosos antes de investir em pixel art.

Ao apertar **F5**, o jogo abre na **Fronteira bárbara**, a primeira fase da fatia vertical: Daniel acorda na neblina, atravessa a mata, cai numa emboscada e é salvo por Lucius. A fase de teste antiga continua em `scenes/test_level.tscn` (abra a cena e aperte **F6** para jogar só ela).

## Como rodar

1. Instale o [Godot 4](https://godotengine.org/download) (versão padrão, não a .NET). O projeto foi validado no Godot 4.3.
2. No Godot, clique em **Importar** e escolha o arquivo `project.godot` desta pasta.
3. Com o projeto aberto, aperte **F5** para jogar.

## Controles

| Tecla | Ação |
| --- | --- |
| A / D ou setas | Andar |
| Espaço, W ou seta para cima | Pular (segure para pular mais alto) |
| J | Golpe de gládio |
| K | Arremessar o pilum |
| L ou Shift | Esquiva (fica invencível por um instante) |
| E ou Enter | Avançar o diálogo |
| Tab | Abrir os autos (as provas registradas) |

## Estrutura

| Pasta / arquivo | O que tem |
| --- | --- |
| `project.godot` | Configuração do projeto (resolução 640x360, pixel art nítido) |
| `scenes/` | As cenas: jogador, inimigo, pilum, a Fronteira e a fase de teste |
| `scripts/controls.gd` | Registra os controles do teclado |
| `scripts/player.gd` | Daniel: movimento, pulo, ataque, arremesso, esquiva e vida |
| `scripts/enemy.gd` | Bárbaro de teste: patrulha, perseguição, dano e morte |
| `scripts/pilum.gd` | A lança de arremesso |
| `scripts/greybox_level.gd` | Base das fases: monta as plataformas e liga a vida ao HUD |
| `scripts/frontier.gd` | Fronteira bárbara: mapa, neblina, fundo com árvores e os eventos da emboscada |
| `scripts/test_level.gd` | Plataformas da fase de teste |
| `scripts/dialogue_data.gd` | **Todas as falas do jogo.** Para escrever uma cena, edite este arquivo |
| `scripts/dialogue_manager.gd` | Controla o diálogo atual e guarda os autos |
| `scripts/dialogue_box.gd` | Caixa de texto, retrato e painel dos autos |
| `scripts/dialogue_trigger.gd` | Área que começa um diálogo quando Daniel entra nela |

Os números que definem a sensação do jogo (velocidade, altura do pulo, duração da esquiva) aparecem no **Inspetor** do Godot ao selecionar o nó `Player`, e podem ser ajustados sem mexer no código.

## Diálogos e autos

As falas ficam em `scripts/dialogue_data.gd`, separadas do código que as mostra. Uma fala com `"record": true` entra nos **autos**, as provas que Daniel vai usar nos interrogatórios. Para colocar uma cena na fase, adicione um nó `Area2D` com o script `dialogue_trigger.gd` e escreva o nome da cena em **Dialogue Id** no Inspetor.

Uma fala também pode ter `"event"`: o nome de algo que acontece na fase junto com ela. Na Fronteira, a fala "Daniel, abaixa!" tem `"event": "lucius_aparece"`, e o `frontier.gd` faz o machado passar e Lucius surgir.

## Fronteira bárbara

| Trecho | O que acontece |
| --- | --- |
| Despertar | Daniel acorda na neblina e a primeira conversa começa sozinha |
| Mata | Pedras, galhos e troncos para aprender a pular, sem inimigos |
| Clareira | A emboscada: um machado passa por cima de Daniel, Lucius aparece e dois bárbaros saem da neblina. A clareira se fecha até a luta acabar |
| Resgate | Lucius vai até Daniel e os dois conversam. A neblina se abre e aparece a tela de fim |

Se Daniel morrer na luta, ele volta na entrada da clareira, sem repetir o despertar. O mapa fica na lista `PLATFORMS` do `frontier.gd`.
