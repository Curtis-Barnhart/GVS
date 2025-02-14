extends Node2D

const FileListScene = preload("res://visualfs/FileList.tscn")
const File = GVSClassLoader.visual.file_nodes.File
const FileList = GVSClassLoader.visualfs.FileList

var _all_files: Array[File] = []


static func make_new() -> FileList:
    return FileListScene.instantiate()


static func _index_to_vec(index: int) -> Vector2:
    var ring: int = 1
    var ring_capacity: int = 6
    var segment: float = 2 * PI / 6
    var diameter: float = 200
    
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


func extend_files(files: Array[File]) -> void:
    for file in files:
        self.add_child(file)
        file.interp_movement(FileList._index_to_vec(len(self._all_files)))
        self._all_files.append(file)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
