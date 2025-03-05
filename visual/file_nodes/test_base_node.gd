extends Node2D

const BaseNode = GVSClassLoader.visual.file_nodes.BaseNode

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    ($BaseNode as BaseNode).setup("here is a very long name")
    ($BaseNode as BaseNode).interp_movement(Vector2(600, 600))
