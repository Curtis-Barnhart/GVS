extends Control

const Checkpoint = GVSClassLoader.visualfs.narrator.lesson.Checkpoint
const FSManager = GVSClassLoader.gvm.filesystem.Manager

var _fs_man: FSManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


func setup(
    fs_manager: FSManager
):
    self._fs_man = fs_manager


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
