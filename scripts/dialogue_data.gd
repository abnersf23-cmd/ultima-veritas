extends RefCounted
## Todas as falas do jogo ficam aqui, separadas do código que as mostra.
## Para escrever uma cena nova, crie uma chave nova em DIALOGUES.
##
## Cada fala tem:
##   speaker: quem fala (define o nome e a cor do retrato)
##   text:    o que é dito
##   record:  true se a fala entra nos AUTOS, as provas que Daniel usa
##            nos interrogatórios. Opcional.
##   event:   nome de um acontecimento da fase que dispara junto com a fala
##            (por exemplo, Lucius aparecendo). Opcional.

const DIALOGUES := {
	"fronteira_despertar": [
		{"speaker": "Narrador", "text": "Neblina. Frio. O chão é de terra, não de asfalto."},
		{"speaker": "Daniel", "text": "Onde... onde eu estou?"},
		{"speaker": "Daniel", "text": "Calma. Pensa como advogado: primeiro os fatos, depois as conclusões."},
	],
	"fronteira_emboscada": [
		{"speaker": "Narrador", "text": "Vultos se movem dentro da neblina."},
		{"speaker": "Bárbaro", "text": "É ele! Levem-no para casa!", "record": true},
		{"speaker": "Lucius", "text": "Daniel, abaixa!", "record": true, "event": "lucius_aparece"},
		{"speaker": "Daniel", "text": "Eu nunca segurei uma espada na vida!"},
		{"speaker": "Lucius", "text": "Então aprende agora. Toma meu gládio e o pilum.", "event": "lucius_entrega_arma"},
		{"speaker": "Lucius", "text": "J para o gládio, K para arremessar o pilum, L para esquivar. Se vier machado, abaixa com S."},
	],
	"fronteira_resgate": [
		{"speaker": "Lucius", "text": "Por pouco. Bárbaros não costumam errar duas vezes."},
		{"speaker": "Daniel", "text": "Ele disse \"levem-no para casa\". Casa de quem?"},
		{"speaker": "Lucius", "text": "Bárbaros dizem muita coisa. Quase nada é verdade."},
		{"speaker": "Daniel", "text": "Quem é você?"},
		{"speaker": "Lucius", "text": "Lucius, da guarda da fronteira. Eu estava de patrulha. Foi o destino que me trouxe até aqui.", "record": true},
		{"speaker": "Lucius", "text": "Vamos. Roma vai querer conhecer você."},
	],
}
