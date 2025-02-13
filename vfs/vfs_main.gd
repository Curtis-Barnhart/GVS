extends HBoxContainer

const ClassLoader = preload("res://gvs_class_loader.gd")
const FSManager = ClassLoader.gvm.filesystem.Manager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var fs_man: FSManager = FSManager.new()
    $FsView/SubViewportContainer/SubViewport/FSGraph.setup(fs_man)
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
