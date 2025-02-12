extends Camera2D


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


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


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
