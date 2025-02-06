extends Node2D

@onready var rootdir: FSGDir = $Root
const FSGDir_Obj = preload("res://gvm/filesystem/ui/graph/FSGDir.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var subd0: FSGDir = FSGDir_Obj.instantiate()
    var subd1: FSGDir = FSGDir_Obj.instantiate()
    var subd1_0: FSGDir = FSGDir_Obj.instantiate()
    var subd1_1: FSGDir = FSGDir_Obj.instantiate()
    
    self.rootdir.add_subdir(subd0)
    self.rootdir.add_subdir(subd1)
    subd1.add_subdir(subd1_0)
    subd1.add_subdir(subd1_1)
    

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
