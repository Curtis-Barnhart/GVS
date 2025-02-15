extends Control


const PopupInputScene = preload("res://visualfs/narrator/PopupInput.tscn")
const PopupInput = GVSClassLoader.visualfs.narrator.PopupInput

## TODO: add this to classloader sometime
const JetBrainsMono = preload("res://shared/JetBrainsMonoNerdFontMono-Regular.ttf")

signal user_input(msg: String)
signal user_cancelled

@onready var _border: NinePatchRect = $NinePatchRect
@onready var _ledit: LineEdit = $VBoxContainer/LineEdit
@onready var _container: VBoxContainer = $VBoxContainer
@onready var _cancel_button: TextureButton = $VBoxContainer/Cancel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    self._border.size = self._container.size


static func make_new() -> PopupInput:
    return PopupInputScene.instantiate()


func popup(tree_access: Node) -> void:
    tree_access.get_tree().get_root().add_child(self)


func _on_line_edit_text_submitted(new_text: String) -> void:
    self.user_input.emit(new_text)


func _on_cancel_pressed() -> void:
    self.user_cancelled.emit()
    self.queue_free()


func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        self._on_cancel_pressed()
