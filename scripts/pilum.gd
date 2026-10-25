extends Area2D
## Pilum: a lança de arremesso romana. Voa em arco e some ao bater em algo.

@export var speed := 320.0
@export var fall_gravity := 280.0
@export var damage := 2
@export var lifetime := 2.0

## Definida por quem arremessa, antes de entrar na cena: 1 = direita, -1 = esquerda.
var direction := 1.0

var _velocity := Vector2.ZERO


func _ready() -> void:
	_velocity = Vector2(direction * speed, -60.0)
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	_velocity.y += fall_gravity * delta
	position += _velocity * delta
	rotation = _velocity.angle()
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage, direction)
	queue_free()
