class_name FSGDir
extends Node2D

@onready var area: Area2D = $Area2D
var parent: FSGDir = self
var expanded: bool = true
var data: FSDir = null
var subdirs: Array[FSGDir] = []
@onready var height: float = $Area2D/CollisionShape2D.shape.get_rect().size.y + 60
@onready var width: float = $Area2D/CollisionShape2D.shape.get_rect().size.x + 40
var sub_width: float = 0
@onready var total_width: float = self.width


func add_subdir(subdir: FSGDir) -> void:
    self.add_child(subdir)
    subdir.parent = self
    self.subdirs.push_back(subdir)
    
    var total_width_delta: float = self.modify_subwidth(subdir.total_width)
    print("Adding subdir with width = %f" % subdir.total_width)
    print("New subwidth = %f" % self.sub_width)
    if total_width_delta != 0:
        self.total_width_notifier(total_width_delta)
    
    self.arrange_subnodes()
    

func arrange_subnodes() -> void:
    var offset: float = -self.total_width/2
    print("arranging subnodes for node with total width = %f" % self.total_width)
    for sd in self.subdirs:
        print("Setting x = %f and y = %f" % [offset + (sd.total_width/2), height])
        print("  - node width = %f" % sd.total_width)
        sd.position.y = height
        sd.position.x = offset + (sd.total_width / 2)
        offset += sd.total_width


# Notifies my parent, if existing, that my total width has changed
func total_width_notifier(total_width_d: float) -> void:
    if self.parent != self:
        var parent_total_width_d: float = self.parent.modify_subwidth(total_width_d)
        if parent_total_width_d != 0:
            self.parent.total_width_notifier(parent_total_width_d)
        self.parent.arrange_subnodes()


# Just a mathematical calulation - not to be used to notify anyone
func modify_subwidth(delta: float) -> float:
    var temp: float = self.total_width
    self.sub_width += delta
    self.total_width = max(self.width, self.sub_width)
    return self.total_width - temp


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
