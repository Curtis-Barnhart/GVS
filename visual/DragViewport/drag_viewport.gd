extends SubViewportContainer


## The camera for this viewport (there should only be one viewport)
@onready var cam: Camera2D = $SubViewport/Camera2D
## The camera's location before it starts getting dragged
var camera_origin: Vector2
## Where the user first clicked down
var click_down: Vector2 = Vector2.ZERO
## Whether the camera is currently being dragged
var drag: bool = false


## add_to_scene adds a node to the viewport we contain.
##
## @param node: Node to add to the viewport.
func add_to_scene(node: CanvasItem) -> void:
    $SubViewport.add_child(node)


## moves camera smoothly to location `loc`.
##
## @param loc: location to move the camera to.
func move_cam_to(loc: Vector2) -> void:
    $SubViewport/Camera2D.interp_movement(loc)


## If the user clicks down, start the camera drag process.
## If the user moves the mouse while drag is on,
## move the camera.
##
## @param event: The InputEvent to process.
func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton and self.get_global_rect().has_point(self.get_global_mouse_position()):
    #if event is InputEventMouseButton:
        if event.is_pressed() && not self.drag:
            self.drag = true
            self.camera_origin = self.cam.position
            self.click_down = self.get_global_mouse_position()
        elif event.is_released() && self.drag:
            self.camera_origin = self.cam.position
            self.drag = false


## If the mouse exits the viewport, we want to stop dragging if we were.
func _on_mouse_exited() -> void:
    if self.drag:
        # set camera_origin so that it can be used on next drag
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
        self.cam.position = self.camera_origin - (self.get_global_mouse_position() - self.click_down)
