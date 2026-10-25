extends "res://scripts/greybox_level.gd"
## Fase de teste do greybox: blocos cinza, sem arte, só para sentir
## o movimento e o combate. Para mudar o mapa, edite a lista PLATFORMS.

const PLATFORMS: Array[Rect2] = [
	Rect2(-200, 0, 1400, 200), # chão
	Rect2(140, -50, 90, 12),
	Rect2(300, -100, 90, 12),
	Rect2(460, -60, 140, 12),
	Rect2(700, -40, 40, 40), # degrau
	Rect2(-220, -400, 20, 600), # parede esquerda
	Rect2(1200, -400, 20, 600), # parede direita
]


func _ready() -> void:
	platforms = PLATFORMS
	super()
