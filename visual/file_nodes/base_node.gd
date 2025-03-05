extends Node2D

const BaseNodeScene = preload("res://visual/file_nodes/BaseNode.tscn")
const BaseNode = GVSClassLoader.visual.file_nodes.BaseNode
const MathUtil = GVSClassLoader.shared.Math

signal total_width_changed(width_delta: float)

const LABEL_FONT_SIZE: int = 36
const HEIGHT = 250
const WIDTH = 40

## The width of this node, including the label width
var _self_width: float

## starting position before interpolating movement.
var _start_pos: Vector2 = Vector2.ZERO
## destination position while interpolating movement.
var _dest_pos: Vector2 = Vector2.ZERO
## amount of time left to interpolate. 2 is t=0 and 0 is t=1
var _interp_t: float = 0

## Label to display the node's name
@onready var _label: Label = $Label
## Sprite to display an icon and receive user clicks
@onready var _icon: TextureButton = $Icon
const JetBrainsFont: Font = preload("res://shared/JetBrainsMonoNerdFontMono-Regular.ttf")


## interp_movement tells the FSGDir that it is ready to begin interpolating
## its position over to the location `dest` over the course of 2 seconds.
##
## @param dest: location to move to.
func interp_movement(dest: Vector2) -> void:
    self._start_pos = self.position
    self._dest_pos = dest
    self._interp_t = 2


## Instantiates a new BaseNode
static func make_new() -> BaseNode:
    return BaseNodeScene.instantiate()


func icon_size() -> Vector2:
    return self._icon.size


func change_icon(text: Texture2D) -> void:
    self._icon.texture_normal = text
    self._icon.reset_size()
    self._icon.position = -self._icon.size / 2


func _ready() -> void:
    pass


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
    self._self_width = max(
        self._icon.size.x,
        label_size
    )
    self.total_width_changed.emit(self._self_width + WIDTH)
    self._label.position += Vector2.LEFT * label_size / 2


## Interpolates my position if I am in the middle of being moved.
##
## @param delta: the time passed since the last frame.
func _process(delta: float) -> void:
    if self._interp_t > 0:
        self._interp_t -= delta
        self.position = MathUtil.log_interp_v(
            self._start_pos,
            self._dest_pos,
            (1 - (self._interp_t/2))
        )
        self.queue_redraw()
