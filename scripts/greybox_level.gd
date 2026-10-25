extends Node2D
## Base das fases de greybox: monta as plataformas a partir de uma lista
## de retângulos e liga a vida de Daniel ao HUD.
## Cada fase herda deste script e preenche `platforms` antes de chamar super().

const PLATFORM_COLOR := Color(0.38, 0.38, 0.42)

## Cada Rect2 é (x, y, largura, altura). O chão fica em y = 0.
var platforms: Array[Rect2] = []
var platform_color := PLATFORM_COLOR

@onready var player: CharacterBody2D = $Player
@onready var health_label: Label = $HUD/HealthLabel


func _ready() -> void:
	for rect in platforms:
		create_platform(rect)
	player.health_changed.connect(_on_player_health_changed)
	_on_player_health_changed(player.health, player.max_health)


func create_platform(rect: Rect2, color := platform_color) -> StaticBody2D:
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
	block.color = color
	block.size = rect.size
	block.position = -rect.size / 2.0
	body.add_child(block)

	add_child(body)
	return body


func _on_player_health_changed(current: int, maximum: int) -> void:
	health_label.text = "Vida: %d/%d" % [current, maximum]
