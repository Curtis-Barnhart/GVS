extends SubViewportContainer


## The camera for this viewport (there should only be one viewport)
@onready var cam: Camera2D = $SubViewport/SubSceneRoot/Camera2D
## The camera's location before it starts getting dragged


## add_to_scene adds a node to the viewport we contain.
##
## @param node: Node to add to the viewport.
func add_to_scene(node: CanvasItem) -> void:
    $SubViewport/SubSceneRoot.add_child(node)


## moves camera smoothly to location `loc`.
##
## @param loc: location to move the camera to.
func move_cam_to(loc: Vector2) -> void:
    self.cam.interp_movement(loc)
