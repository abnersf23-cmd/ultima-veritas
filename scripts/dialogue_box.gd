extends CanvasLayer
## Caixa de diálogo com retrato, nome e texto que aparece letra por letra,
## mais o painel dos AUTOS (abre com Tab).
## Também é um autoload, então funciona em qualquer fase.

## Cor do retrato de cada personagem enquanto não temos arte.
const SPEAKER_COLORS := {
	"Daniel": Color(0.86, 0.74, 0.55),
	"Lucius": Color(0.72, 0.22, 0.2),
	"Hilde": Color(0.36, 0.55, 0.38),
	"Narrador": Color(0.4, 0.4, 0.45),
	"Bárbaro": Color(0.3, 0.42, 0.3),
}

@export var characters_per_second := 40.0

var _shown_characters := 0.0

@onready var panel: Panel = $Panel
@onready var portrait: ColorRect = $Panel/Portrait
@onready var name_label: Label = $Panel/NameLabel
@onready var text_label: Label = $Panel/TextLabel
@onready var continue_hint: Label = $Panel/ContinueHint
@onready var records_panel: Panel = $RecordsPanel
@onready var records_list: Label = $RecordsPanel/RecordsList
@onready var record_toast: Label = $RecordToast


func _ready() -> void:
	panel.hide()
	records_panel.hide()
	record_toast.hide()
	Dialogue.line_started.connect(_on_line_started)
	Dialogue.dialogue_finished.connect(_on_dialogue_finished)
	Dialogue.record_added.connect(_on_record_added)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("records"):
		_toggle_records()

	if not panel.visible:
		return

	var total := text_label.get_total_character_count()
	if _shown_characters < total:
		_shown_characters += characters_per_second * delta
		text_label.visible_characters = int(_shown_characters)

	var finished_typing := _shown_characters >= total
	continue_hint.visible = finished_typing

	if Input.is_action_just_pressed("interact"):
		if finished_typing:
			Dialogue.advance()
		else:
			# Apertar no meio da frase mostra a frase inteira.
			_shown_characters = total
			text_label.visible_characters = -1


func _on_line_started(line: Dictionary) -> void:
	var speaker: String = line["speaker"]
	name_label.text = "" if speaker == "Narrador" else speaker
	portrait.color = SPEAKER_COLORS.get(speaker, Color.GRAY)
	text_label.text = line["text"]
	text_label.visible_characters = 0
	_shown_characters = 0.0
	panel.show()


func _on_dialogue_finished(_id: String) -> void:
	panel.hide()


func _on_record_added(_record: Dictionary) -> void:
	record_toast.show()
	var tween := create_tween()
	tween.tween_interval(1.5)
	tween.tween_callback(record_toast.hide)


func _toggle_records() -> void:
	records_panel.visible = not records_panel.visible
	if not records_panel.visible:
		return
	if Dialogue.records.is_empty():
		records_list.text = "Nenhuma prova registrada ainda."
		return
	var lines := PackedStringArray()
	for record in Dialogue.records:
		lines.append("%s: \"%s\"" % [record["speaker"], record["text"]])
	records_list.text = "\n\n".join(lines)
