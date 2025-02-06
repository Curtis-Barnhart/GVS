# What's cool about this guy is that he is guaranteed to send signals when
# anything changes, and he will also do it via signals and take care of all
# of the references to file/dir structures.
# He is also guaranteed to never contain loops in the underlying file structure.

class_name FSManager
extends RefCounted

signal created_dir(path: FSPath)
signal removed_dir(path: FSPath)

var _root: FSDir = FSDir.new("", null)


func _init() -> void:
    # This creates a cyclic references that will never be deleted because of reference counting.
    # This must be manually deleted in func _notification before this object is deconstructed.
    self._root.parent = self._root


# Removes cyclic reference in self.root to itself so that it can be freed
func _notification(what: int) -> void:
    if what == NOTIFICATION_PREDELETE:
        # This would be self._root.parent but for this bug:
        # https://github.com/godotengine/godot/issues/6784
        # https://github.com/godotengine/godot/issues/80834
        # self is null, buf data inside it can still be accessed.
        # I am genuinely not sure what the intended behavior is,
        # but my best guess says that this is a relatively
        # safe/stable thing to do
        _root.parent = null


func contains_file(p: FSPath) -> bool:
    return self._root.get_file(p) != null


func contains_dir(p: FSPath) -> bool:
    return self._get_dir(p) != null


func contains_path(p: FSPath) -> bool:
    return self.contains_file(p) or self.contains_dir(p)


#func write_file(p: FSPath, content: String) -> bool:
    #if p.degen():
        #return false
    #if self.contains_path(p.base()):
        #
    #return false


func _get_dir(p: FSPath) -> FSDir:
    if p.degen():
        return self._root
    return self._root.get_dir(p)


func create_dir(p: FSPath) -> bool:
    var contain_path: FSPath = p.base()
    var new_dir_name: String = p.last()
    
    if new_dir_name == "":
        return false
    
    var contain_dir: FSDir = self._get_dir(contain_path)
    if contain_dir == null:
        return false
    
    if new_dir_name in contain_dir.subdirs.map(func (sd): return sd.name):
        return false
    
    contain_dir.subdirs.push_back(FSDir.new(new_dir_name, contain_dir))
    emit_signal("created_dir", p)
    return true


#func create_dir_nested(p: FSPath) -> bool:
    #if self.contains_dir(p):
        #return false


#func move(p: FSPath) -> bool:
    #return false


#func copy(p: FSPath) -> bool:
    #return false


#func remove_file(p: FSPath) -> bool:
    #return false


func remove_dir(p: FSPath) -> bool:
    var dir: FSDir = self._get_dir(p)
    if dir == self._root or dir == null or (not dir.subdirs.is_empty()):
        return false
    
    var parent: FSDir = dir.parent
    var i: int = parent.subdirs.find(dir)
    parent.subdirs.remove_at(i)
    emit_signal("removed_dir", p)
    return true


#func remove_recursive(p: FSPath) -> bool:
    #return false


## get a list of files in a directory
## @param p: directory to read
func read_dirs_in_dir(p: FSPath) -> Array[FSPath]:
    var dir: FSDir = self._get_dir(p)
    if dir == null:
        return []
    
    return dir.subdirs.map(func (sd): return sd.get_path())
