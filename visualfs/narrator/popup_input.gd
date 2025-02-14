extends Control


const PopupInputScene = preload("res://visualfs/narrator/PopupInput.tscn")
const PopupInput = GVSClassLoader.visualfs.narrator.PopupInput

## TODO: add this to classloader sometime
const JetBrainsMono = preload("res://shared/JetBrainsMonoNerdFontMono-Regular.ttf")

signal user_input(msg: String)
signal user_cancelled

@onready var _border: NinePatchRect = $NinePatchRect
@onready var _container: VBoxContainer = $VBoxContainer
@onready var _ledit: LineEdit = $VBoxContainer/LineEdit
@onready var _cancel_button: TextureButton = $VBoxContainer/Cancel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    self._border.size = self._container.size
    pass # Replace with function body.


static func make_new() -> PopupInput:
    return PopupInputScene.instantiate()


func _on_line_edit_text_submitted(new_text: String) -> void:
    self.user_input.emit(new_text)


func _on_cancel_pressed() -> void:
    self.user_cancelled.emit()
    self.queue_free()


func _on_child_focus_exited() -> void:
    if self.get_viewport().gui_get_focus_owner() not in [
        self._container, self._ledit, self._cancel_button
    ]:
        self.user_cancelled.emit()
        self.queue_free()
