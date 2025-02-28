extends Control

const GVSPopup = GVSClassLoader.visual.popups.GVSPopup
const FileReader = GVSClassLoader.visual.FileReader
const Manager = GVSClassLoader.gvm.filesystem.Manager
const Path = GVSClassLoader.gvm.filesystem.Path
const DragViewport = GVSClassLoader.visual.DragViewport.DragViewport
const FileList = GVSClassLoader.visualfs.FileList
const Menu = GVSClassLoader.visual.buttons.CircleMenu
const File = GVSClassLoader.visual.file_nodes.File

#@onready var _button: TextureButton = $TextureButton
var _man: Manager = Manager.new()
@onready var _viewport: DragViewport = $DragViewport
var _ftree: FileList


func _ready() -> void:
    self._ftree = FileList.make_new()
    self._viewport.add_to_scene(self._ftree)
    
    self._man.created_file.connect(self._ftree.add_file)
    
    for fname: String in ["file0", "file1", "file2"]:
        var p := Path.new([fname])
        self._man.create_file(p)
        var file_vis: File = self._ftree.get_file(p)
        file_vis.connect_to_press(
            func () -> void:
                var menu: Menu = Menu.make_new()
                var read_file := Sprite2D.new()
                read_file.texture = load("res://visual/assets/file.svg")
                var write_file := Sprite2D.new()
                write_file.texture = load("res://icon.svg")
                menu.add_child(read_file)
                menu.add_child(write_file)
                file_vis._icon.disabled = true
                # golly this was a pain in the butt to realize im so dumb lol
                # https://docs.godotengine.org/en/stable/tutorials/2d/2d_transforms.html#window-transform
                menu.position = file_vis.get_viewport().get_screen_transform() * file_vis.get_global_transform_with_canvas() * Vector2.ZERO
                menu.popup(self)
                
                menu.menu_closed.connect(
                    func (x: int) -> void:
                        file_vis._icon.disabled = false
                        print("Selected ", x)
                )
        )    
