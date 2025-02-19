extends HBoxContainer

const FSManager = GVSClassLoader.gvm.filesystem.Manager
const FileList = GVSClassLoader.visualfs.FileList
const DragViewport = GVSClassLoader.visual.DragViewport.DragViewport
const File = GVSClassLoader.visual.file_nodes.File
const Path = GVSClassLoader.gvm.filesystem.Path
const Narrator = GVSClassLoader.visualfs.narrator.Narrator

@onready var viewport: DragViewport = $DragViewport
@onready var narrator: Narrator = $Narrator


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var fs_man: FSManager = FSManager.new()
    var file_list: FileList = FileList.make_new()
    fs_man.created_file.connect(file_list.add_file)
    self.viewport.add_to_scene(file_list)
    
    for x in range(62):
        fs_man.create_file(Path.new([str(x)]))
    
    self.narrator.setup(fs_man, self.viewport)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
