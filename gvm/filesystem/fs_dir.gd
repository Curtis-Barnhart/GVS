class_name FSDir
extends RefCounted


var name: String
var parent: FSDir
# gotta be careful of circular references here,
# which shouldn't be a problem anyways but still
var subdirs: Array[FSDir]
var files: Array[FSFile]

func local_dir(name: String) -> FSDir:
    for d in self.subdirs:
        if d.name == name:
            return d
    return null

func local_file(name: String) -> FSFile:
    for f in self.files:
        if f.name == name:
            return f
    return null

func get_dir(path: FSPath) -> FSDir:
    if path.degen():
        return null
    
    var subdir = self.local_dir(path.base())
    if subdir == null:
        return null
    
    var rest: FSPath = path.tail()
    if rest.degen():
        subdir
    
    return subdir.get_dir(rest)

func get_file(path: FSPath) -> FSFile:
    if path.degen():
        return null
    
    var head: String = path.base()
    var rest: FSPath = path.tail()
    
    if rest.degen():
        return self.local_file(head)
    
    var subdir: FSDir = self.local_dir(head)
    if subdir == null:
        return null
    
    return subdir.get_file(rest)
