extends "res://scripts/greybox_level.gd"
## Fronteira bárbara, a primeira fase da fatia vertical.
## Roteiro: Daniel acorda na neblina, atravessa a mata, sofre a emboscada,
## Lucius aparece para salvá-lo e os dois conversam depois da luta.

const PLATFORMS: Array[Rect2] = [
	# O chão continua além da câmera, para a mata parecer aberta.
	Rect2(-900, 0, 3000, 200),
	# Mata: pedras e troncos para ensinar o pulo sem pressão.
	Rect2(200, -24, 60, 24), # pedra
	Rect2(330, -64, 90, 12), # galho
	Rect2(480, -36, 40, 36), # toco
	Rect2(580, -96, 80, 12), # galho alto
	Rect2(700, -20, 120, 20), # árvore caída
]
## Limites invisíveis da fase: Daniel não passa, mas não se vê parede nenhuma.
const BOUNDS: Array[Rect2] = [
	Rect2(-340, -400, 20, 600),
	Rect2(1440, -400, 20, 600),
]
## A clareira da emboscada fica entre ARENA_LEFT e o limite direito.
const ARENA_LEFT := 860.0
## Se Daniel morrer na luta, ele volta aqui em vez do começo da fase.
const CHECKPOINT := Vector2(940, -1)

## Velocidade de Lucius andando depois da luta (Daniel corre a 130).
const LUCIUS_WALK_SPEED := 70.0

const FOG_CALM := 0.12
const FOG_THICK := 0.26
const FOG_CLEAR := 0.04
const GROUND_COLOR := Color(0.27, 0.24, 0.21)
const CONTROLS_UNARMED := "A/D andar · Espaço pular · S abaixar · L esquiva · E falar · Tab autos"
const CONTROLS_ARMED := "A/D andar · Espaço pular · S abaixar · J gládio · L esquiva · E falar · Tab autos"

## Continua valendo quando a cena recarrega depois da morte.
static var reached_ambush := false

var _enemies_left := 0
var _arena_wall: StaticBody2D
var _fog: ColorRect
var _fog_bands: Array[ColorRect] = []

@onready var lucius: Node2D = $Lucius
@onready var end_label: Label = $HUD/EndLabel
@onready var controls_label: Label = $HUD/ControlsLabel
@onready var item_label: Label = $HUD/ItemLabel
@onready var camera: Camera2D = $Player/Camera2D


func _ready() -> void:
	platforms = PLATFORMS
	platform_color = GROUND_COLOR
	super()
	for rect in BOUNDS:
		create_platform(rect, platform_color, false)
	_create_background()
	_create_fog()
	camera.limit_left = -340
	camera.limit_right = 1460
	camera.limit_bottom = 140
	lucius.hide()
	end_label.hide()
	item_label.hide()
	# Na Fronteira Daniel só ganha o gládio; o pilum vem mais adiante.
	player.has_pilum = false
	_set_armed(reached_ambush)

	for enemy in get_tree().get_nodes_in_group("ambush"):
		enemy.died.connect(_on_enemy_died)
		_enemies_left += 1

	Dialogue.line_started.connect(_on_line_started)
	Dialogue.dialogue_finished.connect(_on_dialogue_finished)

	if reached_ambush:
		player.global_position = CHECKPOINT
	else:
		await get_tree().create_timer(0.6).timeout
		Dialogue.start("fronteira_despertar")


func _exit_tree() -> void:
	# Os sinais são de um autoload, que continua vivo depois desta cena.
	Dialogue.line_started.disconnect(_on_line_started)
	Dialogue.dialogue_finished.disconnect(_on_dialogue_finished)


func _process(delta: float) -> void:
	# As faixas de neblina andam devagar e dão a volta na tela.
	for i in _fog_bands.size():
		var band := _fog_bands[i]
		band.position.x -= (8.0 + i * 5.0) * delta
		if band.position.x < -band.size.x:
			band.position.x = 640.0


func _on_line_started(line: Dictionary) -> void:
	match line.get("event", ""):
		"barbaros_aparecem":
			for enemy in get_tree().get_nodes_in_group("ambush"):
				enemy.appear()
		"lucius_aparece":
			# Primeiro o grito, depois Daniel se abaixa e só então o machado passa.
			_show_lucius()
			var tween := create_tween()
			tween.tween_interval(0.7)
			tween.tween_callback(player.duck.bind(1.2))
			tween.tween_interval(0.25)
			tween.tween_callback(_throw_axe_over_player)
		"lucius_entrega_arma":
			_set_armed(true)
			_show_item("Gládio recebido")
	_turn_to_speaker(line["speaker"])


## Daniel olha para quem está falando; quem fala olha para Daniel.
## Quando o próprio Daniel fala, ele continua olhando para a última pessoa que falou.
func _turn_to_speaker(speaker: String) -> void:
	var node := _speaker_node(speaker)
	if node == null:
		return
	var side := signf(node.global_position.x - player.global_position.x)
	if side != 0.0:
		player.facing = int(side)
	if node == lucius:
		lucius.scale.x = -side


func _speaker_node(speaker: String) -> Node2D:
	match speaker:
		"Lucius":
			return lucius if lucius.visible else null
		"Bárbaro":
			# Quem grita é o bárbaro visível mais perto de Daniel.
			var nearest: Node2D = null
			var best := INF
			for enemy in get_tree().get_nodes_in_group("ambush"):
				var distance := absf(enemy.global_position.x - player.global_position.x)
				if enemy.visible and distance < best:
					nearest = enemy
					best = distance
			return nearest
	return null


func _on_dialogue_finished(id: String) -> void:
	match id:
		"fronteira_emboscada":
			_start_fight()
		"fronteira_resgate":
			reached_ambush = false
			_set_fog(FOG_CLEAR, 2.0)
			end_label.show()


func _start_fight() -> void:
	reached_ambush = true
	_set_fog(FOG_THICK, 0.8)
	# A clareira se fecha sem parede à vista: a neblina engrossa e Daniel não sai.
	_arena_wall = create_platform(Rect2(ARENA_LEFT - 20, -400, 20, 400), platform_color, false)
	for enemy in get_tree().get_nodes_in_group("ambush"):
		enemy.activate()


func _on_enemy_died() -> void:
	_enemies_left -= 1
	if _enemies_left > 0:
		return
	_arena_wall.queue_free()
	_set_fog(FOG_CALM, 1.5)
	# Lucius respira e vai andando até Daniel, sem pressa, antes de falar.
	var side := -1.0 if lucius.global_position.x < player.global_position.x else 1.0
	var target_x := player.global_position.x + side * 30.0
	var distance := absf(target_x - lucius.global_position.x)
	lucius.scale.x = -side # vira de frente para Daniel
	var tween := create_tween()
	tween.tween_interval(0.8)
	tween.tween_property(lucius, "global_position:x", target_x, clampf(distance / LUCIUS_WALK_SPEED, 0.4, 3.5))
	tween.tween_interval(0.4)
	tween.tween_callback(Dialogue.start.bind("fronteira_resgate"))


func _set_armed(value: bool) -> void:
	player.has_sword = value
	controls_label.text = CONTROLS_ARMED if value else CONTROLS_UNARMED


func _show_item(text: String) -> void:
	item_label.text = text
	item_label.modulate.a = 1.0
	item_label.show()
	var tween := create_tween()
	tween.tween_interval(2.0)
	tween.tween_property(item_label, "modulate:a", 0.0, 0.6)
	tween.tween_callback(item_label.hide)


func _show_lucius() -> void:
	lucius.global_position = Vector2(player.global_position.x - 60.0, 0)
	lucius.scale.x = 1.0 # surge à esquerda, olhando para Daniel
	lucius.modulate.a = 0.0
	lucius.show()
	create_tween().tween_property(lucius, "modulate:a", 1.0, 0.3)


## O machado que quase acerta Daniel: passa por cima da cabeça dele.
func _throw_axe_over_player() -> void:
	var axe := ColorRect.new()
	axe.color = Color(0.55, 0.55, 0.6)
	axe.size = Vector2(10, 6)
	axe.pivot_offset = axe.size / 2.0
	var y := player.global_position.y - 22.0
	axe.position = Vector2(player.global_position.x + 260.0, y)
	add_child(axe)
	var tween := create_tween().set_parallel()
	tween.tween_property(axe, "position:x", player.global_position.x - 260.0, 0.5)
	tween.tween_property(axe, "rotation", -TAU * 3.0, 0.5)
	tween.chain().tween_callback(axe.queue_free)


func _create_background() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7 # sempre as mesmas árvores
	# Fundo distante mais claro e lento, fundo próximo mais escuro e rápido.
	var layers := [
		{"scroll": 0.2, "color": Color(0.24, 0.27, 0.32), "count": 6, "width": 26.0},
		{"scroll": 0.5, "color": Color(0.13, 0.15, 0.18), "count": 5, "width": 16.0},
	]
	for layer in layers:
		var parallax := Parallax2D.new()
		parallax.scroll_scale = Vector2(layer["scroll"], 1.0)
		parallax.repeat_size = Vector2(640, 0)
		parallax.repeat_times = 4
		parallax.z_index = -10
		for i in layer["count"]:
			var trunk := ColorRect.new()
			trunk.color = layer["color"]
			var height := rng.randf_range(160.0, 300.0)
			trunk.size = Vector2(layer["width"] * rng.randf_range(0.7, 1.3), height)
			trunk.position = Vector2(i * 640.0 / layer["count"] + rng.randf_range(0, 60), -height)
			parallax.add_child(trunk)
		add_child(parallax)
		move_child(parallax, 0)


func _create_fog() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 1
	add_child(layer)

	_fog = ColorRect.new()
	_fog.color = Color(0.78, 0.82, 0.88, FOG_CALM)
	_fog.size = Vector2(640, 360)
	_fog.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_fog)

	for i in 3:
		var band := ColorRect.new()
		band.color = Color(0.85, 0.88, 0.92, 0.06)
		band.size = Vector2(700, 50 + i * 15)
		band.position = Vector2(i * 220.0, 60 + i * 55)
		band.mouse_filter = Control.MOUSE_FILTER_IGNORE
		layer.add_child(band)
		_fog_bands.append(band)


func _set_fog(alpha: float, duration: float) -> void:
	create_tween().tween_property(_fog, "color:a", alpha, duration)
