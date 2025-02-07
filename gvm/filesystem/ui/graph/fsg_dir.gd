class_name FSGDir
extends Node2D

# This will almost certainly be changed in the future to look better
@onready var label: Label = $Label

@onready var area: Area2D = $Area2D
# Unused right now - is the dir visually expanded
var expanded: bool = true
# height - used to calculate how far below me to put subdirs visually
@onready var height: float = $Area2D/CollisionShape2D.shape.get_rect().size.y + 60
# width - used to calculate how far apart to print subobjects
@onready var width: float = $Area2D/CollisionShape2D.shape.get_rect().size.x + 40
# cumulative width of all my subobjects
var sub_width: float = 0
# total width of myself - max of myself (my level) or my subobjects'
# cumulative total_widths
@onready var total_width: float = self.width


#func remove_subdir(path:FSPath) -> FSGDir:
    #if path.


func add_subdir(subdir: FSGDir) -> void:
    self.add_child(subdir)
    
    var total_width_delta: float = self.modify_subwidth(subdir.total_width)
    #print("Adding subdir with width = %f" % subdir.total_width)
    #print("New subwidth = %f" % self.sub_width)
    if total_width_delta != 0:
        self.total_width_notifier(total_width_delta)
    
    self.arrange_subnodes()


func arrange_subnodes() -> void:
    var offset: float = -self.total_width/2
    #print("arranging subnodes for node with total width = %f" % self.total_width)
    # TODO: someday update this to check for files as well
    for sd in self.get_children() \
                  .filter(func (c): return is_instance_of(c, FSGDir)):
        #print("Setting x = %f and y = %f" % [offset + (sd.total_width/2), height])
        #print("  - node width = %f" % sd.total_width)
        sd.position.y = height
        sd.position.x = offset + (sd.total_width / 2)
        offset += sd.total_width


## Notifies my parent, if existing, that my total width has changed
##
## @param total_width_d: the change in my own width
func total_width_notifier(total_width_d: float) -> void:
    var parent = self.get_parent()
    if is_instance_of(parent, FSGDir):
        var parent_total_width_d: float = parent.modify_subwidth(total_width_d)
        if parent_total_width_d != 0:
            parent.total_width_notifier(parent_total_width_d)
        parent.arrange_subnodes()


## Just a mathematical calulation - not to be used to notify anyone.
## Adds delta to sub_width, then recalculates total_width.
##
## @param delta: amount to add to the sub_width
## @return: the amount that the total_width has changed by since modifying sub_width.
func modify_subwidth(delta: float) -> float:
    var temp: float = self.total_width
    self.sub_width += delta
    self.total_width = max(self.width, self.sub_width)
    return self.total_width - temp


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    pass
