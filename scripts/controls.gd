extends Node
## Registra os controles do jogo quando ele abre.
## Também daria para criar em Projeto > Configurações do Projeto > Mapa de Entrada;
## aqui ficam no código para ser fácil de ler e mudar.

const ACTIONS := {
	"move_left": [KEY_A, KEY_LEFT],
	"move_right": [KEY_D, KEY_RIGHT],
	"jump": [KEY_SPACE, KEY_W, KEY_UP],
	"crouch": [KEY_S, KEY_DOWN],
	"attack": [KEY_J],
	"throw": [KEY_K],
	"dodge": [KEY_L, KEY_SHIFT],
	"interact": [KEY_E, KEY_ENTER],
	"records": [KEY_TAB],
}


func _ready() -> void:
	for action in ACTIONS:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for key in ACTIONS[action]:
			var event := InputEventKey.new()
			event.physical_keycode = key
			InputMap.action_add_event(action, event)
