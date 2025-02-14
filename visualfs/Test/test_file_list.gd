extends Node2D

const FileList = GVSClassLoader.visualfs.FileList
const File = GVSClassLoader.visual.file_nodes.File


@onready var f_list: FileList = $FileList

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var t: float = 0.25
    for x in range(130):
        var file: File = File.make_new()
        self.f_list.extend_files([file])
        await get_tree().create_timer(t).timeout
        t = max(0.95*t, 1.0/16)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
