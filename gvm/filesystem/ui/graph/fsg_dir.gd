class_name FSGDir
extends Node2D

# This will almost certainly be changed in the future to look better
@onready var label: Label = $Label

@onready var sprite: Sprite2D = $Sprite2D
@onready var area: Area2D = $Area2D
## height - used to calculate how far below me to put subdirs visually
@onready var height: float = $Area2D/CollisionShape2D.shape.get_rect().size.y + 160
## width - used to calculate how far apart to print subobjects
@onready var width: float = $Area2D/CollisionShape2D.shape.get_rect().size.x + 40
@onready var icon_height: float = $Area2D/CollisionShape2D.shape.get_rect().size.y
## cumulative width of all my subobjects
var sub_width: float = 0
## total width of myself - max of myself (my level) or my subobjects'
## cumulative total_widths
@onready var total_width: float = self.width

## starting position before interpolating movement.
var start_pos: Vector2 = Vector2.ZERO
## destination position while interpolating movement.
var dest_pos: Vector2 = Vector2.ZERO
## amount of time left to interpolate. 2 is t=0 and 0 is t=1
var interp_t: float = 0


func set_texture(texture: Texture2D) -> void:
    self.sprite.texture = texture
    self.queue_redraw()


## interp_movement tells the FSGDir that it is ready to begin interpolating
## its position over to the location `dest` over the course of 2 seconds.
##
## @param dest: location to move to.
func interp_movement(dest: Vector2) -> void:
    self.start_pos = self.position
    self.dest_pos = dest
    self.interp_t = 2


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
        sd.interp_movement(Vector2(offset + (sd.total_width / 2), self.height))
        #sd.position.y = height
        #sd.position.x = offset + (sd.total_width / 2)
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


func _draw() -> void:
    var parent = self.get_parent()
    if is_instance_of(parent, FSGDir):
        var diff: Vector2 = parent.global_position - self.global_position
        var begin: Vector2 = Vector2.ZERO
        var up: Vector2 = begin + Vector2(0, diff.y / 2)
        var right: Vector2 = up + Vector2(diff.x, 0)
        var up_again: Vector2 = right + up + Vector2(0, parent.icon_height / 2)
        self.draw_line(begin, up, Color.STEEL_BLUE, 7)
        self.draw_line(up, right, Color.STEEL_BLUE, 7)
        self.draw_line(right, up_again, Color.STEEL_BLUE, 7)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if self.interp_t > 0:
        self.interp_t -= delta
        self.position = utils_math.log_interp_v(
            self.start_pos,
            self.dest_pos,
            (1 - (self.interp_t/2))
        )
        self.queue_redraw()
