extends "res://visual/file_nodes/base_node.gd"

const FileScene = preload("res://visual/file_nodes/File.tscn")
const File = GVSClassLoader.visual.file_nodes.File

@onready var _icon: TextureButton = $Icon


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    super._ready()


## Instantiates a new BaseNode
static func make_new() -> File:
    return FileScene.instantiate()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    super._process(delta)


func connect_to_press(functor: Callable) -> void:
    self._icon.pressed.connect(functor)
