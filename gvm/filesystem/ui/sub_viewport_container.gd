extends SubViewportContainer

@onready var cam: Camera2D = $SubViewport/Camera2D
@onready var label: Label = self.get_parent().find_child("Label")
var camera_origin: Vector2
var click_down: Vector2 = Vector2.ZERO
var drag: bool = false


func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton and self.get_global_rect().has_point(self.get_global_mouse_position()):
        if event.is_pressed() && not self.drag:
            self.drag = true
            self.click_down = self.get_global_mouse_position()
        elif event.is_released() && self.drag:
            self.camera_origin = self.cam.position
            self.drag = false


func _on_mouse_exited() -> void:
    print("mouse exited!")
    if self.drag:
        self.camera_origin = self.cam.position
    self.drag = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    self.camera_origin = self.cam.position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if self.drag:
        self.label.text = " : ".join([str(self.camera_origin), str(self.get_global_mouse_position()), str(self.click_down)])
        self.cam.position = self.camera_origin - (self.get_global_mouse_position() - self.click_down)
    else:
        self.label.text = "No drag"
