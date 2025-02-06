## Class for containing information about file paths.
## All methods on FSPath are const.
class_name FSPath
extends RefCounted
    
var _segments: Array[String]


func _init(segments: Array[String]) -> void:
    # at some point should we filter this for empty strings?
    self._segments = segments


func degen() -> bool:
    return self._segments.is_empty()


func head() -> String:
    if self.degen():
        return ""
    return self._segments[0]


func tail() -> FSPath:
    if self.degen():
        return FSPath.new([])
    return FSPath.new(self._segments.slice(1))


func base() -> FSPath:
    if self.degen():
        return FSPath.new([])
    return FSPath.new(self._segments.slice(0, self._segments.size() - 1))


func last() -> String:
    if self.degen():
        return ""
    return self._segments[-1]


func compose(other: FSPath) -> FSPath:
    return FSPath.new(self._segments + other._segments)


func as_string(abs: bool = true) -> String:
    if self.degen():
        return "/"
    if abs:
        return "/" + "/".join(self._segments)
    return "/".join(self._segments)
