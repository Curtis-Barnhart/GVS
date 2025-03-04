extends Node2D

const SelfScene = preload("res://visual/FileTree/Directory.tscn")
const ClassLoader = preload("res://gvs_class_loader.gd")
const Directory_C = ClassLoader.visual.FileTree.Directory
const MathUtil = ClassLoader.shared.Math

## Label to display the directory name
## This will almost certainly be changed in the future to look better
@onready var label: Label = $Label
## Sprite to display a folder icon
@onready var sprite: Sprite2D = $Sprite2D
## Area2D keeps track of our size (which the sprite does not have)
## and also would allow for mouse interaction more easily if we wanted in the future.
@onready var area: Area2D = $Area2D
## height - used to calculate how far below me to put subdirs visually
@onready var height: float = ($Area2D/CollisionShape2D as CollisionShape2D).shape.get_rect().size.y + 120
## width - used to calculate how far apart to print subobjects
## The width is whichever is wider - the folder icon or the name label
var width: float
## Icon height gives the exact height of the icon (technically the area2d)
## which we use for drawing paths. The height variable has additional room
## for spacing, which icon_height does not
@onready var icon_height: float = ($Area2D/CollisionShape2D as CollisionShape2D).shape.get_rect().size.y
## cumulative width of all my subobjects
var sub_width: float = 0
## total width of myself - max of myself (my level) or my subobjects'
## cumulative total_widths
@onready var total_width: float = self.width
## Having the font loaded lets us determine how large a text label will be
## before that text label actually has to be rendered,
## which is necessary because we have to give our width to our parents on the
## same frame that we are instantiated before our label has time to render
const JetBrainsFont: Font = preload("res://shared/JetBrainsMonoNerdFontMono-Regular.ttf")
## Is my path to my parent currently highlighted or not
var path_glow: bool = false

## starting position before interpolating movement.
var start_pos: Vector2 = Vector2.ZERO
## destination position while interpolating movement.
var dest_pos: Vector2 = Vector2.ZERO
## amount of time left to interpolate. 2 is t=0 and 0 is t=1
var interp_t: float = 0


## interp_movement tells the FSGDir that it is ready to begin interpolating
## its position over to the location `dest` over the course of 2 seconds.
##
## @param dest: location to move to.
func interp_movement(dest: Vector2) -> void:
    self.start_pos = self.position
    self.dest_pos = dest
    self.interp_t = 2


## Adds a subdirectory to this directory.
##
## @param subdir: the subdirectory to add.
## @param subdir_name: the name to put on the label of the subdirectory.
func add_subdir(subdir: Directory_C, subdir_name: String) -> void:
    self.add_child(subdir)
    subdir.setup(subdir_name)
    
    var total_width_delta: float = self.modify_subwidth(subdir.total_width)
    if total_width_delta != 0:
        self.total_width_notifier(total_width_delta)
    
    self.arrange_subnodes()


## Arrange the positions of my children directories so they are evenly spaced
## (taking into account their own children, so that no one's children overlap).
func arrange_subnodes() -> void:
    var offset := -self.total_width/2
    # TODO: someday update this to check for files as well
    for sd: Directory_C in self.get_children() \
                  .filter(func (c: Node) -> bool: return is_instance_of(c, Directory_C)):
        sd.interp_movement(Vector2(offset + (sd.total_width / 2), self.height))
        offset += sd.total_width


## Notifies my parent, if existing, that my total width has changed
##
## @param total_width_d: the change in my own width
func total_width_notifier(total_width_d: float) -> void:
    if is_instance_of(self.get_parent(), Directory_C):
        var parent: Directory_C = self.get_parent()
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


static func make_new() -> Directory_C:
    return SelfScene.instantiate()


## Correctly calculates my own size and positions my name label accordingly.
## This should be called after the node has entered the scene.
##
## @param label_str: the name to assign this directory.
func setup(label_str: String) -> void:
    self.label.text = label_str
    var label_size := JetBrainsFont.get_string_size(label_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 36).x
    self.width = max(
        ($Area2D/CollisionShape2D as CollisionShape2D).shape.get_rect().size.x,
        label_size
    ) + 40
    self.total_width = self.width
    self.label.position.x = -label_size / 2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass


## Draws my connection to my parent (and highlights it if applicable).
func _draw() -> void:
    if is_instance_of(self.get_parent(), Directory_C):
        var parent: Directory_C = self.get_parent()
        var lcolor: Color
        if self.path_glow:
            lcolor = Color.CRIMSON
        else:
            lcolor = Color.STEEL_BLUE
        var diff: Vector2 = parent.global_position - self.global_position
        var begin: Vector2 = Vector2.ZERO
        var up: Vector2 = begin + Vector2(0, diff.y / 2)
        var right: Vector2 = up + Vector2(diff.x, 0)
        var up_again: Vector2 = right + up + Vector2(0, parent.icon_height / 2)
        self.draw_line(begin, up, lcolor, 7)
        self.draw_line(up, right, lcolor, 7)
        self.draw_line(right, up_again, lcolor, 7)


## Interpolates my position if I am in the middle of being moved.
##
## @param delta: the time passed since the last frame.
func _process(delta: float) -> void:
    if self.interp_t > 0:
        self.interp_t -= delta
        self.position = MathUtil.log_interp_v(
            self.start_pos,
            self.dest_pos,
            (1 - (self.interp_t/2))
        )
        self.queue_redraw()
