extends CharacterBody2D
## Bárbaro de teste: patrulha, persegue Daniel quando ele chega perto
## e é empurrado para trás ao ser atingido.
## Com `active` desligado ele fica escondido na neblina até alguém chamar activate().

signal died

@export var max_health := 3
@export var patrol_speed := 40.0
@export var chase_speed := 75.0
@export var chase_distance := 110.0
@export var gravity := 900.0
@export var contact_damage := 1
@export var stun_duration := 0.3
@export var active := true

var health := 0
var direction := 1

var _stun_timer := 0.0
var _player: Node2D

@onready var visual: Node2D = $Visual
@onready var body_rect: ColorRect = $Visual/Body
@onready var edge_check: RayCast2D = $Visual/EdgeCheck
@onready var contact_area: Area2D = $ContactArea


func _ready() -> void:
	health = max_health
	if not active:
		hide()
		_set_awake(false)


## Faz o bárbaro sair da neblina e entrar na luta.
func activate() -> void:
	if active:
		return
	active = true
	_set_awake(true)
	modulate.a = 0.0
	show()
	create_tween().tween_property(self, "modulate:a", 1.0, 0.4)


func _set_awake(awake: bool) -> void:
	set_physics_process(awake)
	contact_area.set_deferred("monitoring", awake)
	$CollisionShape2D.set_deferred("disabled", not awake)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	if _stun_timer > 0.0:
		_stun_timer -= delta
		velocity.x = move_toward(velocity.x, 0.0, 400.0 * delta)
	else:
		_update_movement()
	move_and_slide()
	visual.scale.x = direction
	_damage_player_on_contact()


func take_damage(amount: int, from_direction: float) -> void:
	if health <= 0:
		return
	health -= amount
	_stun_timer = stun_duration
	velocity = Vector2(from_direction * 120.0, -90.0)
	_flash()
	if health <= 0:
		_die()


func _update_movement() -> void:
	if _player == null:
		_player = get_tree().get_first_node_in_group("player")

	var speed := patrol_speed
	var sees_player := (
		_player != null
		and absf(_player.global_position.y - global_position.y) < 30.0
		and absf(_player.global_position.x - global_position.x) < chase_distance
	)
	if sees_player:
		direction = 1 if _player.global_position.x > global_position.x else -1
		speed = chase_speed
		# Persegue, mas não se joga da plataforma.
		if is_on_floor() and not edge_check.is_colliding():
			speed = 0.0
	elif is_on_floor() and (is_on_wall() or not edge_check.is_colliding()):
		direction *= -1
	velocity.x = direction * speed


func _damage_player_on_contact() -> void:
	if _stun_timer > 0.0 or health <= 0:
		return
	for body in contact_area.get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(contact_damage, signf(body.global_position.x - global_position.x))


func _flash() -> void:
	body_rect.modulate = Color(3.0, 3.0, 3.0)
	var tween := create_tween()
	tween.tween_property(body_rect, "modulate", Color.WHITE, 0.15)


func _die() -> void:
	died.emit()
	set_physics_process(false)
	contact_area.set_deferred("monitoring", false)
	$CollisionShape2D.set_deferred("disabled", true)
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.25)
	tween.tween_callback(queue_free)
