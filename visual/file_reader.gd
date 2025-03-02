extends Control

const SelfScene = preload("res://visual/FileReader.tscn")
const FileReader = GVSClassLoader.visual.FileReader

@onready var _label: RichTextLabel = $RichTextLabel


static func make_new() -> FileReader:
    return SelfScene.instantiate()


func load_text(text: String) -> void:
    self._label.text = text
