extends Control

const FileTree = GVSClassLoader.visual.FileTree
const FManager = GVSClassLoader.gvm.filesystem.Manager
const DragViewport = GVSClassLoader.visual.DragViewport.DragViewport
const Path = GVSClassLoader.gvm.filesystem.Path

var ft: FileTree
var fs_man: FManager
var path_dict: Dictionary[int, Button] = {}
@onready var color_button: CheckButton = $Color
@onready var flash_button: CheckButton = $Flash


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
    
    await GVSGlobals.wait(2)
    self.ft.hl_server.push_flash_to_tree_nodes(Color.RED, 1, Path.ROOT, Path.new(["dir0", "dir1"]))
    #var id: int = self.ft.hl_server.push_color_to_tree_nodes(Color.RED, Path.ROOT, Path.new(["dir0", "dir1"]))
    

func fs_click(p: Path) -> void:
    var color: Color
    if self.color_button.toggle_mode:
        color = Color.RED
    else:
        color = Color.GREEN
    
    if self.flash_button.toggle_mode:
        self.ft.hl_server.push_flash_to_tree_nodes(color, 1, Path.ROOT, p)
