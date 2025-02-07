# At least right now, this class is NOT meant to be used raw.
# It should be used by a FSManager.

class_name FSDir
extends RefCounted

var name: String
var parent: FSDir
# gotta be careful of circular references here,
# which shouldn't be a problem anyways but still
var subdirs: Array[FSDir] = []
var files: Array[FSFile] = []


func _init(d_name: String, d_parent: FSDir) -> void:
    self.name = d_name
    self.parent = d_parent


func get_path() -> FSPath:
    if self.parent == self:
        # I wonder if this will have to be changed eventually
        return FSPath.new([])
    return self.parent.get_path().compose(FSPath.new([self.name]))


func local_dir(local_name: String) -> FSDir:
    for d in self.subdirs:
        if d.name == local_name:
            return d
    if local_name == "..":
        return self.parent
    if local_name == ".":
        return self
    return null


func local_file(local_name: String) -> FSFile:
    for f in self.files:
        if f.name == local_name:
            return f
    return null


func get_dir(path: FSPath) -> FSDir:
    if path.degen():
        return null
    
    var subdir = self.local_dir(path.head())
    if subdir == null:
        return null
    
    var rest: FSPath = path.tail()
    if rest.degen():
        return subdir
    
    return subdir.get_dir(rest)


func get_file(path: FSPath) -> FSFile:
    if path.degen():
        return null
    
    var head: String = path.head()
    var rest: FSPath = path.tail()
    
    if rest.degen():
        return self.local_file(head)
    
    var subdir: FSDir = self.local_dir(head)
    if subdir == null:
        return null
    
    return subdir.get_file(rest)
