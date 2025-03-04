extends Node2D

const FileListScene = preload("res://visualfs/FileList.tscn")
const Path = GVSClassLoader.gvm.filesystem.Path
const File = GVSClassLoader.visual.file_nodes.File
const FileList = GVSClassLoader.visualfs.FileList

signal file_clicked(path: Path)

# [name/path of file, file object]
var _all_data := []
# these map from strings and files respectively to references in _all_data
var _name_to_data := {}
var _file_to_data := {}


static func make_new() -> FileList:
    return FileListScene.instantiate()


static func _index_to_vec(index: int) -> Vector2:
    assert(index >= 0, "Index must be non-negative")
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


## Gets a File object from the file_list.
##
## @param path: path to the file to retrieve.
## @return: File object if contained else null.
func get_file(path: Path) -> File:
    if self._name_to_data.has(path.as_string()):
        return self._name_to_data.get(path.as_string())[1]
    return null


# TODO: update to write in file name with right size
func add_file(path: Path) -> void:
    assert(
        self.get_file(path) == null,
        "Path already contained in FileList"
    )
    var file: File = File.make_new()
    self._all_data.push_back([path, file])
    self._name_to_data[path.as_string()] = self._all_data.back()
    self._file_to_data[file] = self._all_data.back()
    self.add_child(file)
    
    file.label.text = path.as_string(false) # TODO: this is the part to replace
    file.interp_movement(FileList._index_to_vec(self._all_data.size() - 1))
    
    file._icon.pressed.connect(func () -> void: self.file_clicked.emit(path))


func remove_file(path: Path) -> void:
    var path_file: Array = self._name_to_data[path.as_string()]
    assert(path_file != null, "FileList didn't contian file to remove.")
    var index: int = self._all_data.find(path_file)
    
    self._all_data.remove_at(index)
    self._name_to_data.erase(path.as_string())
    self._file_to_data.erase(path_file[1])
    path_file[1].queue_free()
        
    for new_index in range(index, self._all_data.size()):
        self._all_data[new_index][1].interp_movement(FileList._index_to_vec(new_index))
