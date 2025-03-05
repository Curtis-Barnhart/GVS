extends Node2D

const SelfScene = preload("res://visual/FileTree.tscn")
const FileTree = GVSClassLoader.visual.FileTree2
const Path = GVSClassLoader.gvm.filesystem.Path
const TNode = GVSClassLoader.visual.file_nodes.TreeNode

## Texture for a normal directory
const dir_text: Texture2D = preload("res://visual/assets/directory.svg")
## Texture for the current working directory
const cwd_text: Texture2D = preload("res://visual/assets/cwd.svg")
## Texture for a file
const file_texture = preload("res://visual/assets/file.svg")

## Map from strings of paths to the TreeNode objects
var _all_nodes: Dictionary = {}
## Path to the cwd
var _cwd: Path = Path.ROOT
## Origin of the last highlighted path
var _hl_origin: Path = Path.ROOT
## Last highlighted path (so we can unhighlight it when we want to highlight a new one)
var _hl_path: Path = Path.ROOT


static func make_new() -> FileTree:
    return SelfScene.instantiate()


# origin and path must be in simplified form
func highlight_path(origin: Path, path: Path) -> void:
    # TODO: make this better
    for any_node: TNode in self._all_nodes.values():
        if any_node._path_glow:
            any_node._path_glow = false
            any_node.z_index = 0
            any_node.queue_redraw()
        
    # highlight new path
    self._hl_origin = origin
    self._hl_path = path
    var complete_hl: Path = origin.compose(path)
    while origin.as_string() != complete_hl.as_string():
        var next_hop: String = path.head()
        var node_to_highlight: TNode
        if next_hop == "..":
            node_to_highlight = self._all_nodes[origin.as_string()]
            node_to_highlight._path_glow = true
            node_to_highlight.z_index = 1
            node_to_highlight.queue_redraw()
        elif next_hop == ".":
            pass
        else:
            node_to_highlight = self._all_nodes[origin.extend(next_hop).as_string()]
            node_to_highlight._path_glow = true
            node_to_highlight.z_index = 1
            node_to_highlight.queue_redraw()
        origin = origin.extend(next_hop)
        path = path.tail()
    # TODO: figure out if this is necessary
    self.queue_redraw()


## Changes whatever visual artifact denotes the cwd.
## Also moves the camera to center on the new cwd
##
## @param new_p: The path to the new cwd. Must be in simplest form.
## @param old_p: Path to the former cwd. Must be in simplest form.
# TODO: Consider not using the private variables here
func change_cwd(new_p: Path, old_p: Path) -> void:
    (self._all_nodes[old_p.as_string()] as TNode).change_icon(dir_text)
    (self._all_nodes[new_p.as_string()] as TNode).change_icon(cwd_text)


## create_dir creates a node in the visual graph
## and ensures all other elements have their position adjusted accordingly.
##
## @param p: Path to the node to create.
##      p's parent directory (p.base()) must be a valid path in this graph,
##      and also must be a simplified absolute path.
## @param texture: Texture to give to the node
func create_node(p: Path, texture: Texture2D) -> void:
    var parent: TNode = self._all_nodes.get(p.base().as_string())
    assert(parent != null,
        "Attempted TNode creation with nonexistent parent"
    )
    var child := TNode.make_new()
    parent.add_subnode(child, p.last())
    self._all_nodes[p.as_string()] = child
    child.change_icon(texture)


func create_node_dir(p: Path) -> void:
    self.create_node(p, dir_text)


func create_node_file(p: Path) -> void:
    self.create_node(p, file_texture)


## remove_dir removes a directory from the visual graph
## and ensures all other elements have their position adjusted accordingly.
##
## @param p: Path to the directory to remove.
##      p must be a valid path in the visual graph,
##      and also must be a simplified absolute path.
func remove_node(p: Path) -> void:
    var node: TNode = self._all_nodes.get(p.as_string())
    assert(node != null,
        "Attempted TNode removal from FileTree it did not belong to."
    )
    assert(p.as_string() != "/",
        "Attempted removal of root TNode."
    )
    var parent_node: TNode = self._all_nodes.get(p.base().as_string())
    parent_node.remove_subnode(node)
    node.queue_free()
    self._all_nodes.erase(p.as_string())


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    self._all_nodes["/"] = TNode.make_new()
    self.add_child(self._all_nodes["/"] as Node)
    (self._all_nodes["/"] as TNode).setup("/")
    self.change_cwd(Path.new([]), Path.new([]))


func node_rel_pos_from_path(p: Path) -> Vector2:
    return self._all_nodes.get(p.as_string()).global_position - self.global_position
