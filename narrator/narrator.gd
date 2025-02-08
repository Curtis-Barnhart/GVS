extends Control

var expanded: bool = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    pass


func _on_button_pressed() -> void:
    if self.expanded:
        self.custom_minimum_size.y = 160
    else:
        self.custom_minimum_size.y = 600
    
    self.expanded = not self.expanded
