extends Control

const SelfScene = preload("res://visual/SimpleInput.tscn")
const SimpleInput = GVSClassLoader.visual.SimpleInput

signal user_cancelled
signal user_entered(msg: String)

@onready var _label: Label = $Label
@onready var _line_edit: LineEdit = $LineEdit


static func make_new() -> SimpleInput:
    return SelfScene.instantiate()


func setup(msg: String) -> void:
    self._label.text = msg


func _on_line_edit_text_submitted(new_text: String) -> void:
    self.user_entered.emit(new_text)
    self.queue_free()


func _on_cancel_pressed() -> void:
    self.user_cancelled.emit()
    self.queue_free()


func _on_confirm_pressed() -> void:
    self.user_entered.emit(self._line_edit.text)
    self.queue_free()
