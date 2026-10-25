extends Node2D
## Fase de teste do greybox: blocos cinza, sem arte, só para sentir
## o movimento e o combate. Para mudar o mapa, edite a lista PLATFORMS.

## Cada Rect2 é (x, y, largura, altura). O chão fica em y = 0.
const PLATFORMS: Array[Rect2] = [
	Rect2(-200, 0, 1400, 200), # chão
	Rect2(140, -50, 90, 12),
	Rect2(300, -100, 90, 12),
	Rect2(460, -60, 140, 12),
	Rect2(700, -40, 40, 40), # degrau
	Rect2(-220, -400, 20, 600), # parede esquerda
	Rect2(1200, -400, 20, 600), # parede direita
]
const PLATFORM_COLOR := Color(0.38, 0.38, 0.42)

@onready var player: CharacterBody2D = $Player
@onready var health_label: Label = $HUD/HealthLabel


func _ready() -> void:
	for rect in PLATFORMS:
		_create_platform(rect)
	player.health_changed.connect(_on_player_health_changed)
	_on_player_health_changed(player.health, player.max_health)


func _create_platform(rect: Rect2) -> void:
	var body := StaticBody2D.new()
	body.position = rect.get_center()
	body.collision_layer = 1
	body.collision_mask = 0

	var shape := RectangleShape2D.new()
	shape.size = rect.size
	var collision := CollisionShape2D.new()
	collision.shape = shape
	body.add_child(collision)

	var block := ColorRect.new()
	block.color = PLATFORM_COLOR
	block.size = rect.size
	block.position = -rect.size / 2.0
	body.add_child(block)

	add_child(body)


func _on_player_health_changed(current: int, maximum: int) -> void:
	health_label.text = "Vida: %d/%d" % [current, maximum]
