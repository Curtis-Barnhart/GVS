# Call me an idiot, but this class is only supposed to be used
# with a backing fs_manager.
# The fs_manager handles the logic, and this handles the display.

extends Node2D

## The backing file system which this visual representation tracks.
var fs_man: FSManager = null
## We let FSManager handle all file system logic - no need to implement it twice.
## Instead, all files/dirs are stored flat in this dict by their path.
var all_nodes: Dictionary = {}
## Path to the cwd
var cwd: FSPath = FSPath.new([])
## The camera that will end up being a child of this node (will be set in _ready().
## This seems like pretty sloppy code to me. Figure out who owns the camera better later.
var camera: Camera2D = null

## Texture for a normal directory
const dir_text: Texture2D = preload("res://shared/folder.svg")
## Texture for the current working directory
const cwd_text: Texture2D = preload("res://shared/folder_cwd.svg")

## FSGDir Scene object so we can spawn new ones
const FSGDir_Obj = preload("res://gvm/filesystem/ui/graph/FSGDir.tscn")


## Changes whatever visual artifact denotes the cwd.
##
## @param p: The path to the cwd. Must be in simplest form.
func change_cwd(new_p: FSPath, old_p: FSPath) -> void:
    self.all_nodes[old_p.as_string()].set_texture(dir_text)
    var new_cwd: FSGDir = self.all_nodes[new_p.as_string()]
    new_cwd.set_texture(cwd_text)
    self.camera.interp_movement(new_cwd.position)


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
    self.change_cwd(FSPath.new([]), FSPath.new([]))
    
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
    # Disgusting. Fix this (later).
    self.camera = self.get_children().filter(func (c): return is_instance_of(c, Camera2D))[0]
    

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    pass
