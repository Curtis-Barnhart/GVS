# Call me an idiot, but this class is only supposed to be used
# with a backing fs_manager.
# The fs_manager handles the logic, and this handles the display.

extends Node2D

var fs_man: FSManager = null
var all_nodes: Dictionary = {}
const FSGDir_Obj = preload("res://gvm/filesystem/ui/graph/FSGDir.tscn")

# Highlight current working directory
var display_cwd: bool = true
var cwd: FSPath = FSPath.new([])
@onready var cwd_node: Sprite2D = $CWD


func display_cwd_off() -> void:
    self.cwd_node.visible = false
    self.display_cwd = false


# TODO: Right now it is displayed by being on a different z layer see if there
# is a better way to do this
func display_cwd_on() -> void:
    self.cwd_node.visible = true
    self.display_cwd = true


# expects p to be the simplest path
func change_cwd(p: FSPath) -> void:
    self.cwd_node.get_parent().remove_child(self.cwd_node)
    self.all_nodes[p.as_string()].add_child(self.cwd_node)


## Manual initializer.
## Connects backing FSManager's file structure manipulation signals
## to the methods here that will perform the corresponding actions
## on the visual graph of the filesystem.
##
## @param fs_manager: the FSManager that backs the filesystem this displays.
##      fs_manager should be empty.
func setup(fs_manager: FSManager) -> void:
    self.fs_man = fs_manager
    self.all_nodes["/"] = FSGDir_Obj.instantiate()
    self.add_child(self.all_nodes["/"])
    self.all_nodes["/"].label.text = "/"
    self.change_cwd(FSPath.new([]))
    
    fs_manager.created_dir.connect(self.create_dir)
    fs_manager.removed_dir.connect(self.remove_dir)


## create_dir creates a directory in the visual graph
## and ensures all other elements have their position adjusted accordingly.
##
## @param p: Path to the directory to create.
##      p's parent directory (p.base()) must be a valid path in this graph,
##      and also must be a simplified absolute path.
func create_dir(p: FSPath) -> void:
    var parent: FSGDir = self.all_nodes[p.base().as_string()]
    var child: FSGDir = FSGDir_Obj.instantiate()
    parent.add_subdir(child)
    child.label.text = p.last()
    self.all_nodes[p.as_string()] = child


## remove_dir removes a directory from the visual graph
## and ensures all other elements have their position adjusted accordingly.
##
## @param p: Path to the directory to remove.
##      p must be a valid path in the visual graph,
##      and also must be a simplified absolute path.
func remove_dir(p: FSPath) -> void:
    var dir_node: FSGDir = self.all_nodes[p.as_string()]
    var removed_width: float = dir_node.width
    var parent: FSGDir = self.all_nodes[p.base().as_string()]
    parent.remove_child(dir_node)
    var parent_width_delta: float = parent.modify_subwidth(-removed_width)
    parent.total_width_notifier(parent_width_delta)
    parent.arrange_subnodes()
    dir_node.queue_free()
    


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass    
    

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
