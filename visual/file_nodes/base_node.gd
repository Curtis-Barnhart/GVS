extends Node2D

const BaseNodeScene = preload("res://visual/file_nodes/BaseNode.tscn")
const BaseNode = GVSClassLoader.visual.file_nodes.BaseNode
const MathUtil = GVSClassLoader.shared.Math

signal total_width_changed(width_delta: float)

const LABEL_FONT_SIZE: int = 36
const WIDTH_PAD: float = 80
const HEIGHT_PAD: float = 160

var self_width: float
var self_height: float
var total_width: float

## starting position before interpolating movement.
var start_pos: Vector2 = Vector2.ZERO
## destination position while interpolating movement.
var dest_pos: Vector2 = Vector2.ZERO
## amount of time left to interpolate. 2 is t=0 and 0 is t=1
var interp_t: float = 0

## Label to display the node's name
## This will almost certainly be changed in the future to look better
@onready var _label: Label = $Label
## Sprite to display an icon and receive user clicks
@onready var _icon: TextureButton = $Icon
const JetBrainsFont: Font = preload("res://shared/JetBrainsMonoNerdFontMono-Regular.ttf")


## interp_movement tells the FSGDir that it is ready to begin interpolating
## its position over to the location `dest` over the course of 2 seconds.
##
## @param dest: location to move to.
func interp_movement(dest: Vector2) -> void:
    self.start_pos = self.position
    self.dest_pos = dest
    self.interp_t = 2


## Instantiates a new BaseNode
static func make_new() -> BaseNode:
    return BaseNodeScene.instantiate()


func _ready() -> void:
    self.total_width_changed.emit(self._icon.size.x)


## Correctly calculates my own size and positions my name label accordingly.
## This should be called after the node has entered the scene.
##
## @param label_str: the name to assign this directory.
func setup(label_str: String) -> void:
    self._label.text = label_str
    var label_size := JetBrainsFont.get_string_size(
        label_str,
        HORIZONTAL_ALIGNMENT_CENTER,
        -1,
        LABEL_FONT_SIZE
    ).x
    self.self_width = max(
        self._icon.size.x,
        label_size
    ) + 40
    self.total_width = self.self_width
    self._label.position += Vector2.LEFT * label_size / 2


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
