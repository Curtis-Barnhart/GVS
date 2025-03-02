extends Node2D

const FileListScene = preload("res://visualfs/FileList.tscn")
const Path = GVSClassLoader.gvm.filesystem.Path
const File = GVSClassLoader.visual.file_nodes.File
const FileList = GVSClassLoader.visualfs.FileList

## [name/path of file, file object]
var _all_files: Array = []


static func make_new() -> FileList:
    return FileListScene.instantiate()


static func _index_to_vec(index: int) -> Vector2:
    var ring: int = 1
    var ring_capacity: int = 6
    var segment: float = 2 * PI / 6
    var diameter: float = 320
    
    if index == 0:
        return Vector2.ZERO
    
    index -= 1
    while index >= ring_capacity:
        index -= ring_capacity
        ring += 1
        ring_capacity = floor(2 * PI * ring)
        segment = 2*PI / ring_capacity
    
    return Vector2(diameter * ring, 0).rotated(index * segment)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


func get_file(path: Path) -> File:
    var index: int = self._all_files                       \
                         .map(func (pair: Array) -> String: return pair[0]) \
                         .find(path.as_string(false))
    if index == -1:
        return null
    return self._all_files[index][1]


# TODO: update to write in file name with right size
func add_file(path: Path) -> void:
    assert(
        path.as_string() not in
        self._all_files.map(func (pair: Array) -> String: return pair[0]),
        "Path already contained in FileList"
    )
    var file: File = File.make_new()
    self.add_child(file)
    file.label.text = path.as_string(false) # TODO: this is the part to replace
    file.interp_movement(FileList._index_to_vec(len(self._all_files)))
    self._all_files.append([path.as_string(false), file])


func remove_file(path: Path) -> void:
    var index: int = self._all_files                       \
                         .map(func (pair: Array) -> String: return pair[0]) \
                         .find(path.as_string(false))
    assert(index != -1, "FileList didn't contain file to remove")
    var file: File = self._all_files[index][1]
    file.queue_free()
    self._all_files.remove_at(index)
    
    for new_index in range(index, self._all_files.size()):
        self._all_files[new_index][1].interp_movement(FileList._index_to_vec(new_index))
