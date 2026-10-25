extends RefCounted
## Todas as falas do jogo ficam aqui, separadas do código que as mostra.
## Para escrever uma cena nova, crie uma chave nova em DIALOGUES.
##
## Cada fala tem:
##   speaker: quem fala (define o nome e a cor do retrato)
##   text:    o que é dito
##   record:  true se a fala entra nos AUTOS, as provas que Daniel usa
##            nos interrogatórios. Opcional.

const DIALOGUES := {
	"fronteira_resgate": [
		{"speaker": "Narrador", "text": "Neblina. Frio. O chão é de terra, não de asfalto."},
		{"speaker": "Daniel", "text": "Onde... onde eu estou?"},
		{"speaker": "Lucius", "text": "Daniel, abaixa!", "record": true},
		{"speaker": "Lucius", "text": "Por pouco. Bárbaros não costumam errar duas vezes."},
		{"speaker": "Daniel", "text": "Quem é você?"},
		{"speaker": "Lucius", "text": "Lucius, da guarda da fronteira. Eu estava de patrulha. Foi o destino que me trouxe até aqui.", "record": true},
		{"speaker": "Lucius", "text": "Vamos. Roma vai querer conhecer você."},
	],
}
