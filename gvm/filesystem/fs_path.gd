## Class for containing information about file paths.
## All methods on FSPath are const.
class_name FSPath
extends RefCounted

static var ROOT: FSPath = FSPath.new([])
## Stores segments of path (each dir on the way/file name)
var _segments: PackedStringArray


## @param segments: the segments of this path (the parts of the path that would
##      be separated by "/"s).
func _init(segments: PackedStringArray) -> void:
    # at some point should we filter this for empty strings?
    self._segments = segments


## @return: True if the path is degenerate, False otherwise.
func degen() -> bool:
    return self._segments.is_empty()


## @return: The first segment of the path if present, else "".
func head() -> String:
    if self.degen():
        return ""
    return self._segments[0]


## @return: New FSPath instance containing all segments except the first one.
func tail() -> FSPath:
    if self.degen():
        return FSPath.new([])
    return FSPath.new(self._segments.slice(1))


## @return: New FSPath instance containing all segments except the last one.
func base() -> FSPath:
    if self.degen():
        return FSPath.new([])
    return FSPath.new(self._segments.slice(0, self._segments.size() - 1))


## @return: The last segment of this path.
func last() -> String:
    if self.degen():
        return ""
    return self._segments[-1]


## Concats two paths together.
##
## @param other: path to add to the end of this path.
## @return: New FSPath containing all segments from both this and other.
func compose(other: FSPath) -> FSPath:
    return FSPath.new(self._segments + other._segments)


## @return: New FSPath with the given name appended to the end of this path.
func extend(name: String) -> FSPath:
    if name == "":
        return self
    return FSPath.new(self._segments + PackedStringArray([name]))


## Returns a string representation of this path.
##
## @param absolute: Whether the path is absolute (i.e. begins with "/").
## @return: string representation of this path.
func as_string(absolute: bool = true) -> String:
    if self.degen():
        return "/"
    if absolute:
        return "/" + "/".join(self._segments)
    return "/".join(self._segments)


## Creates an FSPath from a string, taking into account whether it is
## relative or absolute and using self as a potential cwd.
##
## @param s: string to turn into FSPath.
## @return: Absolute FSPath of `s`.
func as_cwd(s: String) -> FSPath:
    if s.begins_with("/"):
        return FSPath.new(s.split("/", false))
    else:
        return self.compose(FSPath.new(s.split("/", false)))
