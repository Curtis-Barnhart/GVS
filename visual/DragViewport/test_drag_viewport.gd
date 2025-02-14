extends Control

const DragViewport = GVSClassLoader.visual.DragViewport.DragViewport
@onready var vp: DragViewport = $DragViewport


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var label: Label = Label.new()
    label.text = "Hello world!"
    self.vp.add_to_scene(label)
    self.vp.move_cam_to(Vector2(-100, -100))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
