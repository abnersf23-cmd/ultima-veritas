# Ultima Veritas

RPG de ação 2D lateral numa Roma que nunca caiu, onde uma profecia falsa traz um advogado do nosso mundo para o centro de uma conspiração.

> *Ultima veritas*: "a última verdade", em latim.

## Estado atual: greybox

O projeto está na fase de **greybox**: tudo é feito de blocos coloridos, sem arte, para testar se andar, pular e lutar estão gostosos antes de investir em pixel art.

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

## Estrutura

| Pasta / arquivo | O que tem |
| --- | --- |
| `project.godot` | Configuração do projeto (resolução 640x360, pixel art nítido) |
| `scenes/` | As cenas: jogador, inimigo, pilum e a fase de teste |
| `scripts/controls.gd` | Registra os controles do teclado |
| `scripts/player.gd` | Daniel: movimento, pulo, ataque, arremesso, esquiva e vida |
| `scripts/enemy.gd` | Bárbaro de teste: patrulha, perseguição, dano e morte |
| `scripts/pilum.gd` | A lança de arremesso |
| `scripts/test_level.gd` | Monta as plataformas da fase de teste |

Os números que definem a sensação do jogo (velocidade, altura do pulo, duração da esquiva) aparecem no **Inspetor** do Godot ao selecionar o nó `Player`, e podem ser ajustados sem mexer no código.
