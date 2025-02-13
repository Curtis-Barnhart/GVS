extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var label: Label = Label.new()
    print(typeof(label))
    print(is_instance_of(label, Label))
    print(is_instance_of(label, Node))
    label.text = "Hello world!"
    $DragViewport.add_to_scene(label)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
