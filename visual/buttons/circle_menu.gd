extends Node2D

var _children: Array
var _rad_in: float = 60
var _rad_out: float = 150
var _selected: int = -1

signal menu_closed(selection: int)


func popup(tree_access: Node) -> void:
    tree_access.get_tree().get_root().add_child(self)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    self._children = self.get_children() \
                         .filter(func (child: Node) -> bool: return child is Sprite2D)
    
    var segment_width: float = 2*PI / len(self._children)
    for i in range(len(self._children)):
        self._children[i].position = Vector2((self._rad_out - self._rad_in)/2 + self._rad_in, 0).rotated(segment_width * (i + 0.5)) + Vector2.ZERO


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    pass


func _draw() -> void:
    draw_circle(Vector2.ZERO, self._rad_in, Color.STEEL_BLUE, false, 6)
    draw_circle(Vector2.ZERO, self._rad_out, Color.STEEL_BLUE, false, 6)
    var segment_width: float = 2*PI / len(self._children)
    for child_index in range(len(self._children)):
        var line_start: Vector2 = Vector2(self._rad_in, 0).rotated(segment_width * child_index)
        draw_line(
            Vector2.ZERO + line_start,
            Vector2.ZERO + self._rad_out/self._rad_in*line_start,
            Color.STEEL_BLUE,
            6
        )
    
    if self._selected != -1:
        draw_arc(
            Vector2.ZERO,
            self._rad_in,
            segment_width * self._selected,
            segment_width * (1 + self._selected),
            64,
            Color.FIREBRICK,
            8
        )
        draw_arc(
            Vector2.ZERO,
            self._rad_out,
            segment_width * self._selected,
            segment_width * (1 + self._selected),
            64,
            Color.FIREBRICK,
            8
        )
        var line_start: Vector2 = Vector2(self._rad_in, 0).rotated(segment_width * self._selected)
        draw_line(Vector2.ZERO + line_start, Vector2.ZERO + self._rad_out/self._rad_in*line_start, Color.FIREBRICK, 8)
        line_start = Vector2(self._rad_in, 0).rotated(segment_width * (1 + self._selected))
        draw_line(Vector2.ZERO + line_start, Vector2.ZERO + self._rad_out/self._rad_in*line_start, Color.FIREBRICK, 8)


func _input(event: InputEvent) -> void:
    if (event is InputEventMouseButton):
        if (not event.is_pressed()):
            self.queue_free()
            self.menu_closed.emit(self._selected)
    elif (event is InputEventMouseMotion):
        var new_select: int = -1
        if Vector2.ZERO.distance_to(event.position - self.position) < self._rad_in:
            if new_select != self._selected:
                self._selected = new_select
                self.queue_redraw()
            return
        var angle: float = Vector2(100, 0).angle_to(event.position - self.position)
        if angle < 0:
            angle += 2*PI
        new_select = floor(angle / (2*PI / len(self._children)))
        if new_select != self._selected:
            self._selected = new_select
            self.queue_redraw()
    queue_redraw() # TODO: remove?
