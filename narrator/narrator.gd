extends Control

var expanded: bool = true
@onready var label: RichTextLabel = $VBoxContainer/RichTextLabel
@onready var next: Button = $VBoxContainer/Next


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    pass


func _on_button_pressed() -> void:
    if self.expanded:
        self.custom_minimum_size.y = 160
        self.label.hide()
        self.next.hide()
    else:
        self.label.show()
        self.next.show()
        self.custom_minimum_size.y = 600
    
    self.expanded = not self.expanded
