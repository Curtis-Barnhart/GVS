extends TextEdit

signal user_entered


# I don't understand why this is called when something else has been clicked on
# shouldn't I not have the focus??
# edit - perhaps its because the other objects you had in mind aren't things
# that actually take focus like user input? Then _everyone_ receives input,
# not just them.
func _input(event: InputEvent) -> void:
    if (
        event is InputEventKey
        and event.is_pressed()
        and event.keycode == KEY_ENTER
        and self.get_viewport().gui_get_focus_owner() == self
    ):
        self.user_entered.emit()
        get_viewport().set_input_as_handled()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    pass
