## Class for containing information about file paths.
## All methods on FSPath are const.
class_name FSPath
extends RefCounted
    
var _segments: Array[String]

func _init(segments: Array[String]) -> void:
    self._segments = segments

func degen() -> bool:
    return self._segments.is_empty()

func base() -> String:
    if self.degen():
        return ""
    return self._segments[0]

func tail() -> FSPath:
    if self.degen():
        return FSPath.new([])
    return FSPath.new(self._segments.slice(1))
