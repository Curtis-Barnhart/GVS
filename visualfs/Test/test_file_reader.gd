extends Control

const GVSPopup = GVSClassLoader.visual.popups.GVSPopup
const FileReader = GVSClassLoader.visual.FileReader
const Manager = GVSClassLoader.gvm.filesystem.Manager
const Path = GVSClassLoader.gvm.filesystem.Path
const DragViewport = GVSClassLoader.visual.DragViewport.DragViewport
const FileList = GVSClassLoader.visualfs.FileList

#@onready var _button: TextureButton = $TextureButton
var _man: Manager = Manager.new()
@onready var _viewport: DragViewport = $DragViewport
var _ftree: FileList


func _ready() -> void:
    self._ftree = FileList.make_new()
    self._viewport.add_to_scene(self._ftree)
    
    self._man.created_file.connect(self._ftree.add_file)
    
    self._man.create_file(Path.new(["file0"]))
    self._man.create_file(Path.new(["file1"]))
    self._man.create_file(Path.new(["file2"]))
    
