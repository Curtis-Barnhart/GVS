extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


func wait(time: float) -> void:
    await get_tree().create_timer(time).timeout
