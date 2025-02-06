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
    self.cwd_node.position = self.all_nodes[p.as_string()].position


## Manual initializer.
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


func create_dir(p: FSPath) -> void:
    var parent: FSGDir = self.all_nodes[self.fs_man.reduce_path(p.base()).as_string()]
    var child: FSGDir = FSGDir_Obj.instantiate()
    parent.add_subdir(child)
    child.label.text = p.last()
    self.all_nodes[p.as_string()] = child


# TODO: Connect
func remove_dir(p: FSPath) -> void:
    return


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass    
    

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
