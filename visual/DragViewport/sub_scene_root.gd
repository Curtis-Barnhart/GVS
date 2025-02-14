extends Node2D


## The camera for this viewport (there should only be one viewport)
@onready var cam: Camera2D = $Camera2D
## The camera's location before it starts getting dragged
var camera_origin: Vector2
## Where the user first clicked down
var click_down: Vector2 = Vector2.ZERO
## Whether the camera is currently being dragged
var drag: bool = false


func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.is_pressed() && not self.drag:
            self.drag = true
            self.camera_origin = self.cam.position
            self.click_down = self.get_viewport().get_mouse_position()
        elif event.is_released() && self.drag:
            self.camera_origin = self.cam.position
            self.drag = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    self.camera_origin = self.cam.position


## If drag is on, move the camera by however far the user's mouse moved.
##
## @param _delta: seconds since last frame (unused)
func _process(_delta: float) -> void:
    if self.drag:
        self.cam.position = self.camera_origin - (self.get_viewport().get_mouse_position() - self.click_down)


func _on_drag_viewport_mouse_exited() -> void:
    if self.drag:
        self.camera_origin = self.cam.position
    self.drag = false
