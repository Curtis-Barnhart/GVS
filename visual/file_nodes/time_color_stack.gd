extends RefCounted

const MathUtils = GVSClassLoader.shared.Math


class TColor extends RefCounted:
    var _color: Color
    var _valid: bool = true
    var _id: int
    
    func _init(color: Color, id: int) -> void:
        self._color = color
        self._id = id
    
    func get_color() -> Color:
        return self._color
    
    func is_valid() -> bool:
        return self._valid


# TODO: time should be a member of TColor, not this
# I don't think you'll add to this, but if you do CHANGE THIS FIRST
class TColorFlash extends TColor:
    var _time: float
    var _original_a: float
    var _duration: float
    
    func _init(color: Color, id: int, duration: float) -> void:
        super._init(color, id)
        self._time = Time.get_unix_time_from_system()
        self._original_a = self._color.a
        self._duration = duration
    
    func get_color() -> Color:
        if self.is_valid():
            self._color.a = MathUtils.half_log_interp(self._original_a, 0,
                (Time.get_unix_time_from_system() - self._time) / self._duration
            )
        return self._color
    
    func is_valid() -> bool:
        return Time.get_unix_time_from_system() - self._time < self._duration


var _stack: Array[TColor] = []
var _default: Color
var _next_id: int = 0


func _init(default_color: Color) -> void:
    self._default = default_color


func is_empty() -> bool:
    self._stack.assign(self._stack.filter(func (tc: TColor) -> bool: return tc.is_valid()))
    return self._stack.is_empty()


func get_current_color() -> Color:
    while self._stack.size() > 0:
        if self._stack[-1].is_valid():
            return self._stack[-1].get_color()
        self._stack.pop_back()
    
    return self._default


func _get_next_id() -> int:
    var id: int = self._next_id
    self._next_id += 1
    if id < 0:
        assert(false, "TimeColorStack color stack overflow... how bro?")
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
