extends HBoxContainer

const FSManager = GVSClassLoader.gvm.filesystem.Manager
const FileList = GVSClassLoader.visualfs.FileList
const DragViewport = GVSClassLoader.visual.DragViewport.DragViewport
const File = GVSClassLoader.visual.file_nodes.File

@onready var viewport: DragViewport = $DragViewport


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var fs_man: FSManager = FSManager.new()
    var file_list: FileList = FileList.make_new()
    self.viewport.add_to_scene(file_list)
    
    for x in range(130):
        var file: File = File.make_new()
        file_list.extend_files([file])

    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
