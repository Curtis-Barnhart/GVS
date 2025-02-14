extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    $BaseNode.interp_movement(Vector2(600, 600))
    pass # Replace with function body.
