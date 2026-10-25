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
		{"speaker": "Narrador", "text": "Vultos saem da neblina. Três homens, armados, olhando direto para Daniel.", "event": "barbaros_aparecem"},
		{"speaker": "Bárbaro", "text": "É ele! Levem-no para casa!", "record": true},
		{"speaker": "Lucius", "text": "Daniel, cuidado! Abaixa!", "record": true, "event": "lucius_aparece"},
		{"speaker": "Daniel", "text": "Espera, espera! Quem é você? Por que eu deveria confiar em você?"},
		{"speaker": "Lucius", "text": "Eles querem te levar. Eu quero te tirar daqui vivo. Escolhe rápido."},
		{"speaker": "Lucius", "text": "Toma, segura isso.", "event": "lucius_entrega_arma"},
		{"speaker": "Daniel", "text": "Eu nunca segurei uma espada na vida!"},
		{"speaker": "Lucius", "text": "Então aprende agora. J para golpear, L para esquivar. Fica perto de mim."},
	],
	"fronteira_resgate": [
		{"speaker": "Lucius", "text": "Por pouco. Bárbaros não costumam errar duas vezes."},
		{"speaker": "Daniel", "text": "Ele disse \"levem-no para casa\". Casa de quem?"},
		{"speaker": "Lucius", "text": "Bárbaros dizem muita coisa. Quase nada é verdade."},
		{"speaker": "Daniel", "text": "Você ainda não me disse quem é."},
		{"speaker": "Lucius", "text": "Lucius, da guarda da fronteira. Eu estava de patrulha. Foi o destino que me trouxe até aqui.", "record": true},
		{"speaker": "Daniel", "text": "Destino. Claro."},
		{"speaker": "Lucius", "text": "Pode desconfiar o quanto quiser. Mas é melhor desconfiar vivo. Vamos, Roma vai querer conhecer você."},
	],
}
