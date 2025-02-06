# Call me an idiot, but this class is only supposed to be used
# with a backing fs_manager.
# The fs_manager handles the logic, and this handles the display.

extends Node2D

var fs_man: FSManager = null
var all_nodes: Dictionary = {}
const FSGDir_Obj = preload("res://gvm/filesystem/ui/graph/FSGDir.tscn")


## Manual initializer.
##
## @param fs_manager: the FSManager that backs the filesystem this displays.
##      fs_manager should be empty.
func setup(fs_manager: FSManager) -> void:
    self.fs_man = fs_manager
    self.all_nodes["/"] = FSGDir_Obj.instantiate()
    self.add_child(self.all_nodes["/"])


# TODO: Connect
func create_dir(p: FSPath) -> void:
    print("Creating dir " + p.as_string())
    var parent: FSGDir = self.all_nodes[p.base().as_string()]
    var child: FSGDir = FSGDir_Obj.instantiate()
    parent.add_subdir(child)
    self.all_nodes[p.as_string()] = child


# TODO: Connect
func remove_dir(p: FSPath) -> void:
    return


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    self.all_nodes["/"] = FSGDir_Obj.instantiate()
    self.add_child(self.all_nodes["/"])
    
    self.create_dir(FSPath.new(["dir0"]))
    self.create_dir(FSPath.new(["dir1"]))
    self.create_dir(FSPath.new(["dir2"]))
    self.create_dir(FSPath.new(["dir0", "subdir00"]))
    self.create_dir(FSPath.new(["dir2", "subdir20"]))
    self.create_dir(FSPath.new(["dir2", "subdir21"]))
    self.create_dir(FSPath.new(["dir2", "subdir22"]))
    self.create_dir(FSPath.new(["dir2", "subdir21", "subdir220"]))
    self.create_dir(FSPath.new(["dir2", "subdir21", "subdir221"]))
    

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
