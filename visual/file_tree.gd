extends Node2D

const SelfScene = preload("res://visual/FileTree.tscn")
const FileTree = GVSClassLoader.visual.FileTree
const Path = GVSClassLoader.gvm.filesystem.Path
const TNode = GVSClassLoader.visual.file_nodes.TreeNode
const TCStack = GVSClassLoader.visual.file_nodes.TimeColorStack
const MathUtils = GVSClassLoader.shared.scripts.Math

signal file_clicked(path: Path)

## Texture for a normal directory
const dir_text: Texture2D = preload("res://visual/assets/directory_open.svg")
## Texture for the current working directory
var cwd_text: Texture2D = preload("res://visual/assets/cwd_open.svg")
## Texture for a file
const file_texture := preload("res://visual/assets/file.svg")
const opened_dir_text := preload("res://visual/assets/directory_open.svg")

## Map from strings of paths to the TreeNode objects
var _all_nodes: Dictionary[String, TNode] = {}
var hl_server: HighlightServer
## Origin of the last highlighted path
## @deprecated
var _hl_origin: Path = Path.ROOT
## Last highlighted path (so we can unhighlight it when we want to highlight a new one)
## @deprecated
var _hl_path: Path = Path.ROOT


class HighlightData extends RefCounted:
    ## Array[Array[path (as a String), tree_node color id]]
    class Record:
        var path: String
        var tcolor_id: int
        
    var _data: Array[Record] = []
    var _id: int
    
    func _init(id: int) -> void:
        self._id = id
    
    func add_data(path: String, tcolor_id: int) -> void:
        var r := Record.new()
        r.path = path
        r.tcolor_id = tcolor_id
        self._data.push_back(r)


## TODO: There are many many problems concerning the z axis here.
## I do not have the time to fix them,
## and at the moment that's okay because it seems that it works well enough.
## I don't think users will generally experience the worst parts of it -
## the worst parts they'll see will be delays in color updates
## and a lack of blending overlapping paths.[br][br]
## TODO: Remove all highlights on destruction?
class HighlightServer extends RefCounted:
    var _highlights: Array[HighlightData] = []
    var _next_id: int = 0
    var _nodes: Dictionary[String, TNode]

    func _init(nodes: Dictionary[String, TNode]) -> void:
        self._nodes = nodes

    func _get_next_id() -> int:
        var id: int = self._next_id
        self._next_id += 1
        assert(id >= 0, "HighlightStack highlight stack overflow... how bro?")
        if self._highlights.size() > 16:
            push_warning("HighlightStack contains %d elements, more than I meant it to hold." % self._highlights.size())

        return id
    
    func _get_nodes_to_color(
        origin: Path,
        path: Path
    ) -> Dictionary[String, Object]:
        var nodes: Dictionary[String, Object] = {}
        
        var dest: Path = origin.compose(path)
        while origin.as_string() != dest.as_string():
            var next_hop: String = path.head()
            if next_hop == "..":
                nodes.set(origin.as_string().simplify_path(), null)
            elif next_hop == ".":
                pass
            else:
                nodes.set(origin.extend(next_hop).as_string().simplify_path(), null)
            origin = origin.extend(next_hop)
            path = path.tail()

        return nodes
    
    func push_color_to_tree_nodes(
        color: Color,
        origin: Path,
        path: Path
    ) -> int:
        var id: int = self._get_next_id()
        var hl_data := HighlightData.new(id)
        
        for file_str: String in self._get_nodes_to_color(origin, path).keys():
            var node: TNode = self._nodes[file_str]
            hl_data.add_data(file_str, node.color_stack.push_solid_color(color))
            node.z_index = 1
            node.queue_redraw()  # TODO: is this necessary?
        
        self._highlights.push_back(hl_data)
        return id

    func push_flash_to_tree_nodes(
        color: Color,
        duration: float,
        origin: Path,
        path: Path
    ) -> void:        
        for file_str: String in self._get_nodes_to_color(origin, path):
            var node: TNode = self._nodes[file_str]
            node.color_stack.push_flash_color(color, duration)
            node.force_redraw = max(node.force_redraw, duration)
            # This is what we would do if we wanted to save the id of the
            # highlight, but I'm assuming I'll never want to do that in the future.
            # If I did, I would also have to create a system similar to the one in
            # TimeColorStack that cleans up expired colors,
            # which I'm too lazy to do now especially because I do doubt
            # that such a system would actually be used.
            # hl_data._data.push_back([file_str, node.color_stack.push_flash_color(color, duration)])
            node.z_index = 1
        
        # TODO: This look dumb? That's cause it is.
        # Unfortunately SceneTree.create_timer is inaccurate to like... tenths of a second??
        # That means that we gotta just kinda spray and pray timers and hope one hits it.
        GVSGlobals.get_tree() \
                  .create_timer(duration) \
                  .timeout.connect(func () -> void: self.clear_z_index(origin, path))
        GVSGlobals.get_tree() \
                  .create_timer(duration + 0.1) \
                  .timeout.connect(func () -> void: self.clear_z_index(origin, path))
    
    func clear_z_index(
        origin: Path,
        path: Path
    ) -> void:
        for file_str: String in self._get_nodes_to_color(origin, path):
            if self._nodes.has(file_str):
                var node: TNode = self._nodes[file_str]
                if node.color_stack.is_empty():
                    node.z_index = 0

    func pop_id(id: int) -> void:
        var index: int = self._highlights \
                            .map(func (hl: HighlightData) -> int: return hl._id) \
                            .find(id)
        if index == -1:
            push_warning("Attempted to pop nonexistant id %d from HighlightStack." % id)
        else:
            for data_point: HighlightData.Record in self._highlights[index]._data:
                if self._nodes.has(data_point.path):
                    self._nodes[data_point.path].color_stack.pop_id(data_point.tcolor_id)
                    if self._nodes[data_point.path].color_stack.is_empty():
                        self._nodes[data_point.path].z_index = 0
                    self._nodes[data_point.path].queue_redraw()

            self._highlights.remove_at(index)


## Constructor for FileTree object.
static func make_new() -> FileTree:
    return SelfScene.instantiate()


## @deprecated
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
            # TODO: This breaks when encoutering . and ..
            # because we don't hold a reference to the fsmanager that can
            # properly reduce complex paths for us
            # Technically we don't need that though because we're working with
            # absolute paths???
            node_to_highlight = self._all_nodes[origin.extend(next_hop).as_string()]
            node_to_highlight._path_glow = true
            node_to_highlight.z_index = 1
            node_to_highlight.queue_redraw()
        origin = origin.extend(next_hop)
        path = path.tail()
    # TODO: figure out if this is necessary
    self.queue_redraw()


## Changes whatever visual artifact denotes the cwd.[br][br]
##
## [param new_p]: The path to the new cwd. Must be in simplest form.[br]
## [param old_p]: Path to the former cwd. Must be in simplest form.
func change_cwd(new_p: Path, old_p: Path) -> void:
    self._all_nodes[old_p.as_string()].change_icon(dir_text)
    self._all_nodes[new_p.as_string()].change_icon(self.cwd_text)


## Queries if a directory is currently visually collapsed.
## [code]p[/code] must be in simplest form.
## Asserts that the directory actually exists.[br][br]
##
## [param p]: Path to the directory to query the collapsedness of.[br]
## [param return]: true if the directory is visually collapsed, otherwise false.
func is_dir_collapsed(p: Path) -> bool:
    var dir: TNode = self._all_nodes.get(p.as_string())
    assert(dir != null,
        "Could not find dir to query collpsedness."
    )
    return dir._collapsed


## Tells a directory is to visually collapse.
## [code]p[/code] must be in simplest form.
## Asserts that the directory actually exists.[br][br]
##
## [param p]: Path to the directory to collapse.[br]
func collapse_dir(p: Path) -> void:
    var dir: TNode = self._all_nodes.get(p.as_string())
    assert(dir != null,
        "Could not find dir to collapse."
    )
    dir.change_icon(dir_text)
    dir.collapse()
    
    
## Tells a directory is to visually uncollapse.
## [code]p[/code] must be in simplest form.
## Asserts that the directory actually exists.[br][br]
##
## [param p]: Path to the directory to uncollapse.[br]
func uncollapse_dir(p: Path) -> void:
    var dir: TNode = self._all_nodes.get(p.as_string())
    assert(dir != null,
        "Could not find dir to uncollapse."
    )
    dir.change_icon(opened_dir_text)
    dir.uncollapse()


## Provides linear interpolated fade in
class FaderIn extends Node:
    var _host: CanvasItem
    var _t0: float
    var _duration: float
    
    static func attach(host: CanvasItem, duration: float) -> void:
        var fader := FaderIn.new()
        host.add_child(fader)
        fader._host = host
        fader._t0 = Time.get_unix_time_from_system()
        fader._duration = duration
    
    func _process(_delta: float) -> void:
        var diff: float = (Time.get_unix_time_from_system() - self._t0) / self._duration
        self._host.modulate.a = min(MathUtils.unary_log_interp(diff), 1)
        if diff > 1:
            self._host.modulate.a = 1
            self.queue_free()


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
        "Attempted TNode creation with nonexistent parent."
    )
    var child := TNode.make_new()
    
    child.modulate.a = 0
    FaderIn.attach(child, 2)
    child.z_index = -1
    self.get_tree().create_timer(2.0).timeout.connect(
        func () -> void:
            child.z_index = 0
    )
    
    parent.add_subnode(child, p.last())
    self._all_nodes[p.as_string()] = child
    child.change_icon(texture)
    child._icon.pressed.connect(func () -> void: self.file_clicked.emit(p))


## Wrapper for create_node that loads a directory texture.[br][br]
##
## [param p]: Path of the directory to create.
func create_node_dir(p: Path) -> void:
    self.create_node(p, opened_dir_text)


## Wrapper for create_node that loads a file texture.[br][br]
##
## [param p]: Path of the file to create
func create_node_file(p: Path) -> void:
    self.create_node(p, file_texture)


## remove_dir removes a directory from the visual graph
## and ensures all other elements have their position adjusted accordingly.[br][br]
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
    self._all_nodes["/"].setup("")
    self._all_nodes["/"].z_index = 0
    self.change_cwd(Path.ROOT, Path.ROOT)
    self._all_nodes["/"]._icon.pressed.connect(func () -> void: self.file_clicked.emit(Path.ROOT))
    
    self.hl_server = HighlightServer.new(self._all_nodes)


func node_rel_pos_from_path(p: Path) -> Vector2:
    return self._all_nodes.get(p.as_string()).global_position - self.global_position


func get_file(p: Path) -> TNode:
    return self._all_nodes[p.as_string()]
