extends Control

var _children: Array
var _menu_open: bool = false
var _rad_in: float = 60
var _rad_out: float = 150
var _selected: int = -1

signal menu_opened
signal menu_closed(selection: int)


func _center() -> Vector2:
    return self.size / 2


func _global_center() -> Vector2:
    return self.global_position + self._center()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    self._children = self.get_children() \
                         .filter(func (child): return child is Sprite2D)
    
    var segment_width: float = 2*PI / len(self._children)
    for i in range(len(self._children)):
        self._children[i].position = Vector2((self._rad_out - self._rad_in)/2 + self._rad_in, 0).rotated(segment_width * (i + 0.5)) + self._center()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass


func _draw() -> void:
    if self._menu_open:
        draw_circle(self._center(), self._rad_in, Color.STEEL_BLUE, false, 6)
        draw_circle(self._center(), self._rad_out, Color.STEEL_BLUE, false, 6)
        var segment_width: float = 2*PI / len(self._children)
        for child_index in range(len(self._children)):
            var line_start: Vector2 = Vector2(self._rad_in, 0).rotated(segment_width * child_index)
            draw_line(
                self._center() + line_start,
                self._center() + self._rad_out/self._rad_in*line_start,
                Color.STEEL_BLUE,
                6
            )
        
        if self._selected != -1:
            draw_arc(
                self._center(),
                self._rad_in,
                segment_width * self._selected,
                segment_width * (1 + self._selected),
                64,
                Color.FIREBRICK,
                8
            )
            draw_arc(
                self._center(),
                self._rad_out,
                segment_width * self._selected,
                segment_width * (1 + self._selected),
                64,
                Color.FIREBRICK,
                8
            )
            var line_start: Vector2 = Vector2(self._rad_in, 0).rotated(segment_width * self._selected)
            draw_line(self._center() + line_start, self._center() + self._rad_out/self._rad_in*line_start, Color.FIREBRICK, 8)
            line_start = Vector2(self._rad_in, 0).rotated(segment_width * (1 + self._selected))
            draw_line(self._center() + line_start, self._center() + self._rad_out/self._rad_in*line_start, Color.FIREBRICK, 8)


func _on_gui_input(event: InputEvent) -> void:
    if (event is InputEventMouseButton):
        if (
            event.is_pressed()
            and not self._menu_open
        ):
            self._menu_open = true
            for child in self._children:
                child.visible = true
            self.queue_redraw()
            self.menu_opened.emit()
        elif (
            not event.is_pressed()
            and self._menu_open
        ):
            self._menu_open = false
            for child in self._children:
                child.visible = false
            self.queue_redraw()
            self.menu_closed.emit(-1)
    elif (
        event is InputEventMouseMotion
        and self._menu_open
    ):
        var new_select: int = -1
        if Vector2.ZERO.distance_to(event.position - self._center()) < self._rad_in:
            if new_select != self._selected:
                self._selected = new_select
                self.queue_redraw()
            return
        var angle: float = Vector2(100, 0).angle_to(event.position - self._center())
        if angle < 0:
            angle += 2*PI
        new_select = floor(angle / (2*PI / len(self._children)))
        if new_select != self._selected:
            self._selected = new_select
            self.queue_redraw()
    self.queue_redraw()
