## Class for containing information about file paths.
## All methods on Path are const.
extends RefCounted

const Path = GVSClassLoader.gvm.filesystem.Path

## ROOT... I guess it saves a few characters? Hopefully it's more readable.
static var ROOT: Path = Path.new([])
## Stores segments of path (each dir on the way/file name)
var _segments: PackedStringArray


## @param segments: the segments of this path (the parts of the path that would
##      be separated by "/"s). It is assumed that these segments are
##      well behaving (nonempty, etc).
func _init(segments: PackedStringArray) -> void:
    self._segments = segments


## @return: True if the path is degenerate, False otherwise.
func degen() -> bool:
    return self._segments.is_empty()


## @return: The first segment of the path if present, else "".
func head() -> String:
    if self.degen():
        return ""
    return self._segments[0]


## @return: New Path instance containing all segments except the first one.
func tail() -> Path:
    if self.degen():
        return Path.new([])
    return Path.new(self._segments.slice(1))


## @return: New Path instance containing all segments except the last one.
func base() -> Path:
    if self.degen():
        return Path.new([])
    return Path.new(self._segments.slice(0, self._segments.size() - 1))


## @return: The last segment of this path.
func last() -> String:
    if self.degen():
        return ""
    return self._segments[-1]


## Concats two paths together.
##
## @param other: path to add to the end of this path.
## @return: New Path containing all segments from both this and other.
func compose(other: Path) -> Path:
    return Path.new(self._segments + other._segments)


## Appends a single segment to a path.
##
## @param name: segment to append to a path.
## @return: New Path with the given name appended to the end of this path.
##      If name is "", returns original path.
func extend(name: String) -> Path:
    if name == "":
        return self
    return Path.new(self._segments + PackedStringArray([name]))


## Returns a string representation of this path.
##
## @param absolute: Whether the path is absolute (i.e. begins with "/").
## @return: string representation of this path.
func as_string(absolute: bool = true) -> String:
    if absolute:
        return "/" + "/".join(self._segments)
    return "/".join(self._segments)


## Creates an Path from a string, taking into account whether it is
## relative or absolute and using self as a potential cwd.
##
## @param s: string to turn into Path.
## @return: Absolute Path of `s`.
func as_cwd(s: String) -> Path:
    if s.begins_with("/"):
        return Path.new(s.split("/", false))
    else:
        return self.compose(Path.new(s.split("/", false)))


## The number of segments in a path.
## If the path is not in simplest terms, gives the number of segments
## in the unsimplified path.[br][br]
##
## [param return]: The number of segments in this path.
func size() -> int:
    return self._segments.size()


## Returns the deepest Path that two Paths have in common starting from root.
## Assumes Paths are not in simplest form and returns a path
## that is not neccessarily in simplest form.[br][br]
##
## [param p]: Other path to find the common parent with this one.[br]
## [param return]: Deepest common parent path between self and [code]p[/code].
func common_with(p: Path) -> Path:
    var mine: Array = Array(self._segments)
    var theirs: Array = Array(p._segments)
    return Path.new(PackedStringArray(
        GStreams.Zip([mine, theirs]) \
                .take_while(func (pair: Array) -> bool:
                                return pair[0] == pair[1]) \
                .as_array()
    ))
    # TODO: please write a test for this
