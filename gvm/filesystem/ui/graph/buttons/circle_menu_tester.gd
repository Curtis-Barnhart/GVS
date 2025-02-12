extends Node2D


const CMenu = preload("res://gvm/filesystem/ui/graph/buttons/CircleMenu.tscn")
var cmenu: Control = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass


func _on_trigger_gui_input(event: InputEvent) -> void:
    if (
        event is InputEventMouseButton
        and event.is_pressed()
    ):
        $Trigger.queue_free()
        print("menu clicked?")
        self.cmenu = CMenu.instantiate()
        self.cmenu.position = $Trigger.position + $Trigger.size / 2
        self.add_child(cmenu)
