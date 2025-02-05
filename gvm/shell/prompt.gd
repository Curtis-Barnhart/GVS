extends TextEdit

signal user_entered


func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.is_pressed():
        if event.keycode == KEY_ENTER:
            emit_signal("user_entered")
            get_viewport().set_input_as_handled()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
