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
## Origin of the last highlighted path
var hl_origin: FSPath = FSPath.new([])
## Last highlighted path (so we can unhighlight it when we want to highlight a new one)
var hl_path: FSPath = FSPath.new([])

## Texture for a normal directory
const dir_text: Texture2D = preload("res://gvm/filesystem/ui/graph/directory.svg")
## Texture for the current working directory
const cwd_text: Texture2D = preload("res://gvm/filesystem/ui/graph/cwd.svg")

## FSGDir Scene object so we can spawn new ones
const FSGDir_Obj = preload("res://gvm/filesystem/ui/graph/FSGDir.tscn")


func highlight_path(origin: FSPath, path: FSPath) -> void:
    # TODO: make this better
    for any_node in self.all_nodes.values():
        if any_node.path_glow:
            any_node.path_glow = false
            any_node.z_index = 0
            any_node.queue_redraw()
        
    # highlight new path
    self.hl_origin = origin
    self.hl_path = path
    var complete_hl: FSPath = origin.compose(path)
    while origin.as_string() != complete_hl.as_string():
        var next_hop: String = path.head()
        var node_to_highlight: FSGDir
        if next_hop == "..":
            node_to_highlight = self.all_nodes[self.fs_man.reduce_path(origin).as_string()]
            node_to_highlight.path_glow = true
            node_to_highlight.z_index = 1
            node_to_highlight.queue_redraw()
        elif next_hop == ".":
            pass
        else:
            node_to_highlight = self.all_nodes[self.fs_man.reduce_path(origin.extend(next_hop)).as_string()]
            node_to_highlight.path_glow = true
            node_to_highlight.z_index = 1
            node_to_highlight.queue_redraw()
        origin = origin.extend(next_hop)
        path = path.tail()
    # TODO: figure out if this is necessary
    self.queue_redraw()


## Gets the vector from myself to a directory in my tree.
##
## @param dir: the directory to get directions to.
## @return: the vector pointing from me to `dir`.
func node_rel_pos(dir: FSGDir) -> Vector2:
    return dir.global_position - self.global_position


## Changes whatever visual artifact denotes the cwd.
## Also moves the camera to center on the new cwd
##
## @param new_p: The path to the new cwd. Must be in simplest form.
## @param old_p: Path to the former cwd. Must be in simplest form.
func change_cwd(new_p: FSPath, old_p: FSPath) -> void:
    self.all_nodes[old_p.as_string()].sprite.texture = dir_text
    var new_cwd: FSGDir = self.all_nodes[new_p.as_string()]
    new_cwd.sprite.texture = cwd_text
    self.camera.interp_movement(self.node_rel_pos(new_cwd))


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
    self.all_nodes["/"].setup("/")
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
    parent.add_subdir(child, p.last())
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
    self.all_nodes.erase(p.as_string())
    


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    # Disgusting. Fix this (later).
    self.camera = self.get_children().filter(func (c): return is_instance_of(c, Camera2D))[0]
    

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    pass
