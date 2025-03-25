# Not a named class
extends Camera2D

const ClassLoader = preload("res://gvs_class_loader.gd")
const MathUtils = ClassLoader.shared.scripts.Math

## starting position before interpolating movement.
var _start_pos: Vector2 = Vector2.ZERO
## destination position while interpolating movement.
var _dest_pos: Vector2 = Vector2.ZERO
## amount of time left to interpolate. 2 is t=0 and 0 is t=1
var _interp_t: float = 0


## interp_movement tells the FSGDir that it is ready to begin interpolating
## its position over to the location `dest` over the course of 2 seconds.
##
## @param dest: location to move to.
func interp_movement(dest: Vector2) -> void:
    self._start_pos = self.position
    self._dest_pos = dest
    self._interp_t = 2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if self._interp_t > 0:
        self._interp_t -= delta
        self.position = MathUtils.log_interp_v(
            self._start_pos,
            self._dest_pos,
            (1 - (self._interp_t/2))
        )
        self.queue_redraw()
