extends "res://visual/file_nodes/base_node.gd"

const FileScene = preload("res://visual/file_nodes/File.tscn")
const File = GVSClassLoader.visual.file_nodes.File


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    super._ready()
    self.icon.gui_input.connect(self._on_icon_gui_input)


## Instantiates a new BaseNode
static func make_new() -> File:
    return FileScene.instantiate()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    super._process(delta)


func _on_icon_gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        print("marking event as handled")
        self.get_viewport().set_input_as_handled()
