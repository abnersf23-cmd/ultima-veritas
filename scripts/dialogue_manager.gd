extends Node
## Controla qual diálogo está acontecendo e guarda os AUTOS:
## as falas marcadas como prova, que Daniel vai usar nos interrogatórios.
## Fica disponível no jogo todo com o nome "Dialogue" (é um autoload).

signal line_started(line: Dictionary)
signal dialogue_finished(id: String)
signal record_added(record: Dictionary)

const DialogueData := preload("res://scripts/dialogue_data.gd")

var is_active := false
var records: Array[Dictionary] = []

var _lines: Array = []
var _index := 0
var _current_id := ""


func start(id: String) -> void:
	if is_active:
		return
	if not DialogueData.DIALOGUES.has(id):
		push_error("Diálogo não encontrado: %s" % id)
		return
	_current_id = id
	_lines = DialogueData.DIALOGUES[id]
	_index = 0
	is_active = true
	_show_current()


func advance() -> void:
	if not is_active:
		return
	_index += 1
	if _index >= _lines.size():
		is_active = false
		dialogue_finished.emit(_current_id)
	else:
		_show_current()


func _show_current() -> void:
	var line: Dictionary = _lines[_index]
	if line.get("record", false):
		_add_record(line)
	line_started.emit(line)


func _add_record(line: Dictionary) -> void:
	var record := {"speaker": line["speaker"], "text": line["text"], "source": _current_id}
	if record in records:
		return
	records.append(record)
	record_added.emit(record)
