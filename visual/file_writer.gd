extends Control

const SelfScene = preload("res://visual/FileWriter.tscn")
const FileWriter = GVSClassLoader.visual.FileWriter

signal write(text: String)
signal quit

@onready var _edit: TextEdit = $VBoxContainer/TextEdit


static func make_new() -> FileWriter:
    return SelfScene.instantiate()


func load_text(text: String) -> void:
    self._edit.text = text


func _on_quit_pressed() -> void:
    self.quit.emit()


func _on_write_pressed() -> void:
    self.write.emit(self._edit.text)
