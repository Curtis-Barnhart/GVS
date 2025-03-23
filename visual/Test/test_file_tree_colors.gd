extends Control

const FileTree = GVSClassLoader.visual.FileTree
const FManager = GVSClassLoader.gvm.filesystem.Manager
const DragViewport = GVSClassLoader.visual.DragViewport.DragViewport
const Path = GVSClassLoader.gvm.filesystem.Path

var ft: FileTree
var fs_man: FManager
var path_dict: Dictionary[int, Button] = {}
@onready var color_button: CheckButton = $Color
var _color_button_on: bool = false
@onready var flash_button: CheckButton = $Flash
var _flash_button_on: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    self.fs_man = FManager.new()
    self.ft = FileTree.make_new()
    fs_man.created_dir.connect(ft.create_node_dir)
    fs_man.removed_dir.connect(ft.remove_node)
    fs_man.created_file.connect(ft.create_node_file)
    fs_man.removed_file.connect(ft.remove_node)
    ($DragViewport as DragViewport).add_to_scene(ft)
    ft.file_clicked.connect(self.fs_click)
    
    self.fs_man.create_dir(Path.new(["dir0"]))
    self.fs_man.create_dir(Path.new(["dir0", "dir0"]))
    self.fs_man.create_dir(Path.new(["dir0", "dir1"]))
    self.fs_man.create_dir(Path.new(["dir1"]))
    self.fs_man.create_dir(Path.new(["dir1", "dir0"]))
    self.fs_man.create_dir(Path.new(["dir1", "dir1"]))
    
    self.color_button.pressed.connect(func () -> void: self._color_button_on = not self._color_button_on)
    self.flash_button.pressed.connect(func () -> void: self._flash_button_on = not self._flash_button_on)
    

func fs_click(p: Path) -> void:
    var color: Color
    if self._color_button_on:
        color = Color.RED
    else:
        color = Color.GREEN
    
    if self._flash_button_on:
        self.ft.hl_server.push_flash_to_tree_nodes(color, 1, Path.ROOT, p)
    else:
        var id: int = self.ft.hl_server.push_color_to_tree_nodes(color, Path.ROOT, p)
        var but := Button.new()
        but.text = str(id)
        but.pressed.connect(
            func () -> void:
                self.ft.hl_server.pop_id(int(but.text))
                but.queue_free()
        )
        $VBoxContainer.add_child(but)
