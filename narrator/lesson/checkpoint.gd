class_name Checkpoint
extends RefCounted

var fs_man: FSManager
var text_screen: RichTextLabel

signal completed


func _init(
    fs_manager: FSManager,
    text_screen: RichTextLabel
) -> void:
    self.fs_man = fs_manager
    self.text_screen = text_screen


func get_text() -> String:
    assert(false, "Checkpoint is an ABC that shouldn't have been instantiated.")
    return ""
