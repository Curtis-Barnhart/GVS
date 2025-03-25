extends RefCounted

const MathUtils = GVSClassLoader.shared.scripts.Math


## TColor is a class that represents a weighted color on a stack of such colors.
class TColor extends RefCounted:
    ## The color this instance represents
    var _color: Color
    ## The weight of this color. A weight of 1 means fully opaque,
    ## and a weight of 0 indicates full transparency.
    var _weight: float
    ## T
    var _id: int
    
    func _init(color: Color, id: int, weight: float = 1.0) -> void:
        self._color = color
        self._weight = weight
        self._id = id
    
    func get_color() -> Color:
        return self._color
    
    func get_weight() -> float:
        return self._weight
    
    func is_valid() -> bool:
        return true


class TColorFlash extends TColor:
    var _t0: float
    var _duration: float
    
    func _init(color: Color, id: int, weight: float = 1.0, duration: float = 1.0) -> void:
        super._init(color, id, weight)
        self._t0 = Time.get_unix_time_from_system()
        self._duration = duration
    
    func get_weight() -> float:
        return MathUtils.half_log_interp(self._weight, 0, (Time.get_unix_time_from_system() - self._t0) / self._duration)
    
    func is_valid() -> bool:
        return Time.get_unix_time_from_system() - self._t0 < self._duration


var _stack: Array[TColor] = []
var _default: Color
var _next_id: int = 0


func _init(default_color: Color) -> void:
    self._default = default_color


func is_empty() -> bool:
    self._stack.assign(self._stack.filter(func (tc: TColor) -> bool: return tc.is_valid()))
    return self._stack.is_empty()


func get_current_color(depth: int = 0) -> Color:
    # Make sure we only have valid colors on
    if depth == 0:
        self._stack.assign(self._stack.filter(func (tc: TColor) -> bool: return tc.is_valid()))
    
    if depth == self._stack.size():
        return self._default
    
    var tcolor: TColor = self._stack[-1 - depth]
    if tcolor.get_weight() < 1:
        return tcolor.get_color().lerp(self.get_current_color(depth + 1), 1 - tcolor.get_weight())
    else:
        return self._stack[-1 - depth].get_color()


func _get_next_id() -> int:
    var id: int = self._next_id
    self._next_id += 1
    assert(id >= 0, "TimeColorStack color stack overflow... how bro?")
    if self._stack.size() > 16:
        push_warning("TimeColorStack contains %d elements, more than I meant it to hold." % self._stack.size())

    return id


func push_solid_color(color: Color) -> int:
    var id: int = self._get_next_id()
    self._stack.push_back(TColor.new(color, id))
    return id


func push_flash_color(color: Color, duration: float = 1) -> int:
    var id: int = self._get_next_id()
    self._stack.push_back(TColorFlash.new(color, id, duration))
    return id


func pop_id(id: int) -> void:
    var index: int = self._stack \
                        .map(func (tc: TColor) -> int: return tc._id) \
                        .find(id)
    if index == -1:
        push_warning("Attempted to pop nonexistant id %d from TimeColorStack." % id)
    self._stack.remove_at(index)
