extends Node2D

const BaseNodeScene = preload("res://visual/file_nodes/BaseNode.tscn")
const BaseNode = GVSClassLoader.visual.file_nodes.BaseNode
const MathUtil = GVSClassLoader.shared.scripts.Math
const JetBrainsFont = GVSClassLoader.shared.fonts.Normal

signal total_width_changed(width_delta: float)

const LABEL_FONT_SIZE: int = 36
const HEIGHT = 250
const WIDTH = 40

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


func _prerendered_label_width() -> float:
    return JetBrainsFont.get_string_size(
        self._label.text,
        HORIZONTAL_ALIGNMENT_CENTER,
        -1,
        LABEL_FONT_SIZE
    ).x


func self_width() -> float:
    return max(self._prerendered_label_width(), self._icon.size.x) + WIDTH


func _ready() -> void:
    self._icon.position = -self._icon.size / 2


## Correctly calculates my own size and positions my name label accordingly.
## This should be called after the node has entered the scene,
## and should be used to set the label for the first time.
##
## @param label_str: the name to assign this directory.
func setup(label_str: String) -> void:
    self._label.text = label_str
    var label_size: float = self._prerendered_label_width()
    self.total_width_changed.emit(max(
        self._icon.size.x, label_size
    ) + WIDTH)
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
