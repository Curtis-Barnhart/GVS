# At least right now, this class is NOT meant to be used raw.
# It should be used by a FSManager.
extends RefCounted

const ClassLoader = preload("res://gvs_class_loader.gd")
const Directory = ClassLoader.gvm.filesystem.Directory
const File = ClassLoader.gvm.filesystem.File
const Path = ClassLoader.gvm.filesystem.Path

var name: String
var parent: Directory
# gotta be careful of circular references here,
# which shouldn't be a problem anyways but still
var subdirs: Array[Directory] = []
var files: Array[File] = []


func _init(d_name: String, d_parent: Directory) -> void:
    self.name = d_name
    self.parent = d_parent


func get_path() -> Path:
    if self.parent == self:
        # I wonder if this will have to be changed eventually
        return Path.new([])
    return self.parent.get_path().compose(Path.new([self.name]))


func local_dir(local_name: String) -> Directory:
    for d in self.subdirs:
        if d.name == local_name:
            return d
    if local_name == "..":
        return self.parent
    if local_name == ".":
        return self
    return null


func local_file(local_name: String) -> File:
    for f in self.files:
        if f._name == local_name:
            return f
    return null


func get_dir(path: Path) -> Directory:
    if path.degen():
        return null
    
    var subdir = self.local_dir(path.head())
    if subdir == null:
        return null
    
    var rest: Path = path.tail()
    if rest.degen():
        return subdir
    
    return subdir.get_dir(rest)


func get_file(path: Path) -> File:
    if path.degen():
        return null
    
    var head: String = path.head()
    var rest: Path = path.tail()
    
    if rest.degen():
        return self.local_file(head)
    
    var subdir: Directory = self.local_dir(head)
    if subdir == null:
        return null
    
    return subdir.get_file(rest)
