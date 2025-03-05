extends Node2D

const SelfScene = preload("res://visual/FileTree/FileTree.tscn")
const ClassLoader = preload("res://gvs_class_loader.gd")
const FileTree_C = ClassLoader.visual.FileTree.FileTree
const Directory_C = ClassLoader.visual.FileTree.Directory
const FSManager = ClassLoader.gvm.filesystem.Manager
const Path = ClassLoader.gvm.filesystem.Path

## The backing file system which this visual representation tracks.
var fs_man: FSManager = null
## We let FSManager handle all file system logic - no need to implement it twice.
## Instead, all files/dirs are stored flat in this dict by their path.
var all_nodes: Dictionary = {}
## Path to the cwd
var cwd: Path = Path.ROOT
## Origin of the last highlighted path
var hl_origin: Path = Path.ROOT
## Last highlighted path (so we can unhighlight it when we want to highlight a new one)
var hl_path: Path = Path.ROOT

## Texture for a normal directory
const dir_text: Texture2D = preload("res://visual/assets/directory.svg")
## Texture for the current working directory
const cwd_text: Texture2D = preload("res://visual/assets/cwd.svg")


func highlight_path(origin: Path, path: Path) -> void:
    # TODO: make this better
    for any_node: Directory_C in self.all_nodes.values():
        if any_node.path_glow:
            any_node.path_glow = false
            any_node.z_index = 0
            any_node.queue_redraw()
        
    # highlight new path
    self.hl_origin = origin
    self.hl_path = path
    var complete_hl: Path = origin.compose(path)
    while origin.as_string() != complete_hl.as_string():
        var next_hop: String = path.head()
        var node_to_highlight: Directory_C
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


## Gets the vector from myself to a directory in my tree given its path.
##
## @param path: the path to the directory to get directions to.
## @return: the vector pointing from me to the directory specified by `path`.
func node_rel_pos_from_path(path: Path) -> Vector2:
    return self.node_rel_pos(self.all_nodes[path.as_string()] as Directory_C)


## Gets the vector from myself to a directory in my tree.
##
## @param dir: the directory to get directions to.
## @return: the vector pointing from me to `dir`.
func node_rel_pos(dir: Directory_C) -> Vector2:
    return dir.global_position - self.global_position


## Changes whatever visual artifact denotes the cwd.
## Also moves the camera to center on the new cwd
##
## @param new_p: The path to the new cwd. Must be in simplest form.
## @param old_p: Path to the former cwd. Must be in simplest form.
func change_cwd(new_p: Path, old_p: Path) -> void:
    self.all_nodes[old_p.as_string()].sprite.texture = dir_text
    var new_cwd: Directory_C = self.all_nodes[new_p.as_string()]
    new_cwd.sprite.texture = cwd_text


## Instantiates new FileTree_C/FSGraph node
static func make_new() -> FileTree_C:
    return SelfScene.instantiate()


## Manual initializer.
## Connects backing FSManager's file structure manipulation signals
## to the methods here that will perform the corresponding actions
## on the visual graph of the filesystem.
##
## @param fs_manager: the FSManager that backs the filesystem this displays.
##      fs_manager should be empty.
func setup(fs_manager: FSManager) -> void:
    self.fs_man = fs_manager
    self.all_nodes["/"] = Directory_C.make_new()
    self.add_child(self.all_nodes["/"] as Node)
    (self.all_nodes["/"] as Directory_C).setup("/")
    self.change_cwd(Path.new([]), Path.new([]))
    
    fs_manager.created_dir.connect(self.create_dir)
    fs_manager.removed_dir.connect(self.remove_dir)


## create_dir creates a directory in the visual graph
## and ensures all other elements have their position adjusted accordingly.
##
## @param p: Path to the directory to create.
##      p's parent directory (p.base()) must be a valid path in this graph,
##      and also must be a simplified absolute path.
func create_dir(p: Path) -> void:
    var parent: Directory_C = self.all_nodes[p.base().as_string()]
    var child: Directory_C = Directory_C.make_new()
    parent.add_subdir(child, p.last())
    self.all_nodes[p.as_string()] = child


## remove_dir removes a directory from the visual graph
## and ensures all other elements have their position adjusted accordingly.
##
## @param p: Path to the directory to remove.
##      p must be a valid path in the visual graph,
##      and also must be a simplified absolute path.
func remove_dir(p: Path) -> void:
    var dir_node: Directory_C = self.all_nodes[p.as_string()]
    var removed_width: float = dir_node.width
    var parent: Directory_C = self.all_nodes[p.base().as_string()]
    parent.remove_child(dir_node)
    var parent_width_delta: float = parent.modify_subwidth(-removed_width)
    parent.total_width_notifier(parent_width_delta)
    parent.arrange_subnodes()
    dir_node.queue_free()
    self.all_nodes.erase(p.as_string())


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass
    # Disgusting. Fix this (later).
    #self.camera = self.get_children().filter(func (c): return is_instance_of(c, Camera2D))[0]
    

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    pass
