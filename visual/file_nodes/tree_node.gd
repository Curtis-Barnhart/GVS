extends "res://visual/file_nodes/base_node.gd"

const SelfScene = preload("res://visual/file_nodes/TreeNode.tscn")
const TNode = GVSClassLoader.visual.file_nodes.TreeNode
const ColorStack = GVSClassLoader.visual.file_nodes.TimeColorStack
const MathUtils = GVSClassLoader.shared.Math


var _sub_width: float = 0
## deprecated in favor of using color_stack to set path color
## @deprecated
var _path_glow: bool = false
var _collapsed: bool = false
var color_stack := ColorStack.new(Color.STEEL_BLUE)


static func make_new() -> TNode:
    return SelfScene.instantiate()


func total_width() -> float:
    if self._collapsed:
        return self.self_width()
    return max(self.self_width(), self._sub_width)


func change_icon(text: Texture2D) -> void:
    var old_width: float = self.total_width()
    
    self._icon.texture_normal = text
    self._icon.reset_size()
    self._icon.position = -self._icon.size / 2
    
    if self.total_width() != old_width:
        self.total_width_changed.emit(self.total_width() - old_width)


## Adds a subdirectory to this directory.
##
## @param subnode: the subdirectory to add.
## @param subdir_name: the name to put on the label of the subdirectory.
##      This should only be set if the subnode is brand new and hasn't been
##      named yet. If the string is empty, this indicates that the subnode
##      has already been assigned a name and knows its own width.
func add_subnode(subnode: TNode, subnode_name: String = "") -> void:
    assert(subnode.get_parent() != self,
        "Added subnode was already a child of this node."
    )
    self.add_child(subnode)
    
    subnode.total_width_changed.connect(self._on_subwidth_change)
    if subnode_name != "":
        subnode.setup(subnode_name)
    else:
        self._on_subwidth_change(subnode.total_width())


func remove_subnode(subnode: TNode) -> void:
    assert(subnode.get_parent() == self,
        "Subnode to be removed was not a child of this node."
    )
    var old_width: float = self.total_width()
    self._sub_width -= subnode.total_width()
    var width_delta: float = total_width() - old_width
    if width_delta != 0:
        self.total_width_changed.emit(width_delta)
    self.remove_child(subnode)
    subnode.total_width_changed.disconnect(self._on_subwidth_change)
    self.arrange_subnodes()


func _on_subwidth_change(delta: float) -> void:
    var old_total: float = self.total_width()
    self._sub_width += delta
    if old_total != self.total_width():
        self.total_width_changed.emit(self.total_width() - old_total)
    self.arrange_subnodes()


## Arrange the positions of my children directories so they are evenly spaced
## (taking into account their own children, so that no one's children overlap).
func arrange_subnodes() -> void:
    var offset := -self._sub_width/2
    for sd: TNode in self.get_children().filter(
        func (c: Node) -> bool: return is_instance_of(c, TNode)
    ):
        sd.interp_movement(Vector2(offset + (sd.total_width() / 2), HEIGHT))
        offset += sd.total_width()
    self.queue_redraw()


## Draws my connection to my parent (and highlights it if applicable).
func _draw() -> void:
    if is_instance_of(self.get_parent(), TNode):
        var parent: TNode = self.get_parent()
        var lcolor: Color = self.color_stack.get_current_color()
        var diff: Vector2 = parent.global_position - self.global_position
        var begin: Vector2 = Vector2(0, -self.icon_size().y / 2)
        var up: Vector2 = Vector2(0, diff.y / 2)
        var right: Vector2 = up + Vector2(diff.x, 0)
        var up_again: Vector2 = right + up + Vector2(0, parent.icon_size().y / 2)
        self.draw_line(begin, up, lcolor, 7)
        self.draw_line(up, right, lcolor, 7)
        self.draw_line(right, up_again, lcolor, 7)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    super._ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    super._process(delta)


func condense_subnodes_recur() -> void:
    for child: TNode in self.get_children().filter(
        func (c: Node) -> bool: return is_instance_of(c, TNode)
    ):
        child.interp_movement(Vector2.ZERO)
        child.condense_subnodes_recur()


func arrange_subnodes_recur() -> void:
    if not self._collapsed:
        self.arrange_subnodes()
        for child: TNode in self.get_children().filter(
            func (c: Node) -> bool: return is_instance_of(c, TNode)
        ):
            child.arrange_subnodes_recur()


func collapse() -> void:
    if not self._collapsed:
        var old_width: float = self.total_width()
        self._collapsed = true
        var delta_width: float = self.total_width() - old_width
        if delta_width != 0:
            self.total_width_changed.emit(delta_width)
        
        self.condense_subnodes_recur()
                
        var temp_timer: SceneTreeTimer = self.get_tree().create_timer(2)
        temp_timer.timeout.connect(
            func () -> void:
                if self._collapsed:
                    for child: TNode in self.get_children().filter(
                        func (c: Node) -> bool: return is_instance_of(c, BaseNode)
                    ):
                        child.visible = false
        )


func uncollapse() -> void:
    if self._collapsed:
        var old_width: float = self.total_width()
        self._collapsed = false
        var delta_width: float = self.total_width() - old_width
        if delta_width != 0:
            self.total_width_changed.emit(delta_width)
        
        for child: TNode in self.get_children().filter(
            func (c: Node) -> bool: return is_instance_of(c, TNode)
        ):
            child.visible = true
        self.arrange_subnodes_recur()
