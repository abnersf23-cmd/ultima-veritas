extends CharacterBody2D
## Daniel no greybox: andar, pular, gládio, pilum e esquiva.
## Os valores com @export aparecem no Inspetor do Godot, então dá para
## ajustar a "sensação" do controle sem mexer no código.

signal health_changed(current: int, maximum: int)

const PILUM_SCENE := preload("res://scenes/pilum.tscn")

enum State { NORMAL, ATTACKING, DODGING, HURT }

@export_group("Movimento")
@export var max_speed := 130.0
@export var acceleration := 900.0
@export var friction := 1100.0

@export_group("Pulo")
@export var jump_velocity := -400.0
@export var gravity := 1160.0
## A queda é mais rápida que a subida: deixa o pulo com mais peso.
@export var fall_gravity_multiplier := 1.4
## Soltar o botão no meio do pulo corta a subida (pulo de altura variável).
@export var jump_cut_multiplier := 0.5
## "Tempo do coiote": ainda dá para pular logo depois de sair da beirada.
@export var coyote_time := 0.1
## Apertar pulo um pouco antes de tocar o chão também conta.
@export var jump_buffer_time := 0.12

@export_group("Combate")
@export var max_health := 5
@export var sword_damage := 1
@export var attack_duration := 0.18
@export var attack_cooldown := 0.12
@export var pilum_cooldown := 0.6
@export var dodge_speed := 260.0
@export var dodge_duration := 0.22
@export var dodge_cooldown := 0.4
@export var hurt_duration := 0.25
@export var hurt_invincibility := 0.8

var state := State.NORMAL
var facing := 1
var health := max_health

var _state_timer := 0.0
var _coyote_timer := 0.0
var _jump_buffer_timer := 0.0
var _attack_cooldown_timer := 0.0
var _pilum_cooldown_timer := 0.0
var _dodge_cooldown_timer := 0.0
var _invincible_timer := 0.0
var _hit_this_swing: Array[Node] = []

@onready var visual: Node2D = $Visual
@onready var body_rect: ColorRect = $Visual/Body
@onready var sword_hitbox: Area2D = $Visual/SwordHitbox
@onready var sword_flash: ColorRect = $Visual/SwordHitbox/SwordFlash


func _ready() -> void:
	health = max_health


func _physics_process(delta: float) -> void:
	_tick_timers(delta)
	match state:
		State.NORMAL:
			_process_normal(delta)
		State.ATTACKING:
			_process_attacking(delta)
		State.DODGING:
			_process_dodging()
		State.HURT:
			_process_hurt(delta)
	move_and_slide()
	_update_visual()


func take_damage(amount: int, from_direction: float) -> void:
	if _invincible_timer > 0.0 or health <= 0:
		return
	health = maxi(health - amount, 0)
	health_changed.emit(health, max_health)
	_end_attack()
	state = State.HURT
	_state_timer = hurt_duration
	_invincible_timer = hurt_invincibility
	velocity = Vector2(from_direction * 140.0, -150.0)
	if health == 0:
		# No greybox, morrer só reinicia a fase.
		get_tree().reload_current_scene.call_deferred()


func _tick_timers(delta: float) -> void:
	_state_timer -= delta
	_coyote_timer -= delta
	_jump_buffer_timer -= delta
	_attack_cooldown_timer -= delta
	_pilum_cooldown_timer -= delta
	_dodge_cooldown_timer -= delta
	_invincible_timer -= delta


func _process_normal(delta: float) -> void:
	_apply_gravity(delta)

	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0.0:
		facing = int(signf(direction))
		velocity.x = move_toward(velocity.x, direction * max_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)

	_handle_jump()

	if Input.is_action_just_pressed("attack") and _attack_cooldown_timer <= 0.0:
		_start_attack()
	elif Input.is_action_just_pressed("throw") and _pilum_cooldown_timer <= 0.0:
		_throw_pilum()
	elif Input.is_action_just_pressed("dodge") and _dodge_cooldown_timer <= 0.0 and is_on_floor():
		_start_dodge()


func _process_attacking(delta: float) -> void:
	_apply_gravity(delta)
	velocity.x = move_toward(velocity.x, 0.0, friction * 0.5 * delta)
	for body in sword_hitbox.get_overlapping_bodies():
		if body.has_method("take_damage") and body not in _hit_this_swing:
			body.take_damage(sword_damage, facing)
			_hit_this_swing.append(body)
	if _state_timer <= 0.0:
		_end_attack()
		state = State.NORMAL


func _process_dodging() -> void:
	velocity.x = facing * dodge_speed
	velocity.y = 0.0
	if _state_timer <= 0.0:
		state = State.NORMAL
		velocity.x = facing * max_speed * 0.5


func _process_hurt(delta: float) -> void:
	_apply_gravity(delta)
	velocity.x = move_toward(velocity.x, 0.0, friction * 0.3 * delta)
	if _state_timer <= 0.0:
		state = State.NORMAL


func _apply_gravity(delta: float) -> void:
	if is_on_floor():
		return
	var current_gravity := gravity
	if velocity.y > 0.0:
		current_gravity *= fall_gravity_multiplier
	velocity.y = minf(velocity.y + current_gravity * delta, 500.0)


func _handle_jump() -> void:
	if is_on_floor():
		_coyote_timer = coyote_time
	if Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = jump_buffer_time

	if _jump_buffer_timer > 0.0 and _coyote_timer > 0.0:
		velocity.y = jump_velocity
		_jump_buffer_timer = 0.0
		_coyote_timer = 0.0

	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= jump_cut_multiplier


func _start_attack() -> void:
	state = State.ATTACKING
	_state_timer = attack_duration
	_hit_this_swing.clear()
	sword_hitbox.set_deferred("monitoring", true)
	sword_flash.visible = true


func _end_attack() -> void:
	if state != State.ATTACKING:
		return
	sword_hitbox.set_deferred("monitoring", false)
	sword_flash.visible = false
	_attack_cooldown_timer = attack_cooldown


func _throw_pilum() -> void:
	var pilum := PILUM_SCENE.instantiate()
	pilum.direction = facing
	pilum.global_position = global_position + Vector2(facing * 10.0, -18.0)
	get_parent().add_child(pilum)
	_pilum_cooldown_timer = pilum_cooldown


func _start_dodge() -> void:
	state = State.DODGING
	_state_timer = dodge_duration
	_invincible_timer = maxf(_invincible_timer, dodge_duration)
	_dodge_cooldown_timer = dodge_duration + dodge_cooldown


func _update_visual() -> void:
	visual.scale.x = facing
	if state == State.DODGING:
		body_rect.modulate.a = 0.4
	elif _invincible_timer > 0.0:
		# Pisca enquanto está invencível depois de levar dano.
		body_rect.modulate.a = 0.3 if int(_invincible_timer * 20.0) % 2 == 0 else 1.0
	else:
		body_rect.modulate.a = 1.0
