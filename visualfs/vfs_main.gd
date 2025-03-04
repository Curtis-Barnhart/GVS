extends HBoxContainer

const FSManager = GVSClassLoader.gvm.filesystem.Manager
const FileList = GVSClassLoader.visualfs.FileList
const DragViewport = GVSClassLoader.visual.DragViewport.DragViewport
const Path = GVSClassLoader.gvm.filesystem.Path
const Narrator = GVSClassLoader.visualfs.narrator.Narrator

@onready var viewport: DragViewport = $DragViewport
@onready var narrator: Narrator = $Narrator


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var fs_man: FSManager = FSManager.new()
    self.narrator.setup(fs_man, self.viewport)
