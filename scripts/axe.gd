extends Area2D
## Machado arremessado pelos bárbaros. Voa reto, na altura da cabeça:
## Daniel escapa abaixando, esquivando ou pulando por cima.

@export var speed := 170.0
@export var damage := 1
@export var lifetime := 3.0

## Definida por quem arremessa, antes de entrar na cena: 1 = direita, -1 = esquerda.
var direction := 1.0

@onready var visual: ColorRect = $Visual


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	position.x += direction * speed * delta
	visual.rotation -= direction * 14.0 * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage, direction)
	queue_free()
