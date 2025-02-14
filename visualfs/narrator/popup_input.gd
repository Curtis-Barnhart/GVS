extends Control

## TODO: add this to classloader sometime
const JetBrainsMono = preload("res://shared/JetBrainsMonoNerdFontMono-Regular.ttf")

@onready var _border: NinePatchRect = $NinePatchRect
@onready var _container: VBoxContainer = $VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    self._border.size = self._container.size
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
