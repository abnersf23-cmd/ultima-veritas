extends Area2D
## Área que começa um diálogo quando Daniel entra nela.
## No greybox ela aparece como um retângulo amarelo transparente.

@export var dialogue_id := ""
@export var size := Vector2(24, 64)
@export var one_shot := true
@export var show_in_game := true

var _used := false


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2 # só o jogador

	var shape := RectangleShape2D.new()
	shape.size = size
	var collision := CollisionShape2D.new()
	collision.shape = shape
	collision.position = Vector2(0, -size.y / 2.0)
	add_child(collision)

	if show_in_game:
		var marker := ColorRect.new()
		marker.color = Color(1.0, 0.85, 0.2, 0.25)
		marker.size = size
		marker.position = Vector2(-size.x / 2.0, -size.y)
		add_child(marker)

	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _used and one_shot:
		return
	if body.is_in_group("player"):
		_used = true
		Dialogue.start(dialogue_id)
