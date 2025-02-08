extends Control

var expanded: bool = true
var target_expanded: bool = true
var expanding_time: float = 0
@onready var min_size: float = $VBoxContainer/Toggle.size.y
const max_size: float = 800
@onready var label: RichTextLabel = $VBoxContainer/RichTextLabel
@onready var next: Button = $VBoxContainer/Next


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if self.expanding_time > 0:
        self.expanding_time -= delta
        if self.target_expanded:
            self.custom_minimum_size.y = utils_math.log_interp(
                self.min_size,
                self.max_size,
                1 - (self.expanding_time / 2)
            )
        else:
            self.custom_minimum_size.y = utils_math.log_interp(
                self.max_size,
                self.min_size,
                1 - (self.expanding_time / 2)
            )
    elif self.target_expanded != self.expanded:
        self.expanded = self.target_expanded
        if self.expanded:
            self.label.show()
            self.next.show()


func _on_button_pressed() -> void:
    if self.expanded:
        self.label.hide()
        self.next.hide()
    
    self.expanding_time = 2
    self.target_expanded = not self.target_expanded
