# What's cool about this guy is that he is guaranteed to send signals when
# anything changes, and he will also do it via signals and take care of all
# of the references to file/dir structures.
# He is also guaranteed to never contain loops in the underlying file structure.

class_name FSManager
extends RefCounted

## path is guaranteed to be in simplest form
signal created_dir(path: FSPath)
## path is guaranteed to be in simplest form
signal removed_dir(path: FSPath)

# Guaranteed non null
var _root: FSDir = FSDir.new("", null)

enum filetype { FILE, DIR, NULL }


func _init() -> void:
    # This creates a cyclic references that will never be deleted because of reference counting.
    # This must be manually deleted in func _notification before this object is deconstructed.
    self._root.parent = self._root


# Removes cyclic reference in self.root to itself so that it can be freed
func _notification(what: int) -> void:
    if what == NOTIFICATION_PREDELETE:
        # This would be self._root.parent but for this bug(?):
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


## Get a FSDir object by path, if it exists.
##
## @param p: Non null path to the directory to get.
## @return: the FSDir object located by path p, or null if it does not exist.
func _get_dir(p: FSPath) -> FSDir:
    if p.degen():
        return self._root
    return self._root.get_dir(p)


## Create a single directory as a subdirectory of an existing directory,
## then emits a single with a path to the created dictionary.
##
## @param p: Non null path to the directory to create.
## @return: true if directory was created, false otherwise.
func create_dir(p: FSPath) -> bool:
    var contain_path: FSPath = p.base()
    var new_dir_name: String = p.last()
    
    if new_dir_name == "":
        return false
    
    # Only create the new directory if the claimed parent is a real directory
    # and that parent does not already contain a directory with the same name.
    var contain_dir: FSDir = self._get_dir(contain_path)
    if contain_dir == null:
        return false
    if new_dir_name in contain_dir.subdirs.map(func (sd): return sd.name):
        return false
   
    p = contain_dir.get_path().extend(new_dir_name)
    contain_dir.subdirs.push_back(FSDir.new(new_dir_name, contain_dir))
    self.created_dir.emit(p)
    #emit_signal("created_dir", p)
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


## Remove a single empty directory that is not the root directory.
##
## @param p: Non null path to the directory to remove.
## @return: true if directory was removed, false otherwise.
func remove_dir(p: FSPath) -> bool:
    var dir: FSDir = self._get_dir(p)
    if dir == self._root or dir == null or (not dir.subdirs.is_empty()):
        return false
    
    p = self.reduce_path(p)
    var parent: FSDir = dir.parent
    # TODO: I'm sure there's a method to remove it directly?
    var i: int = parent.subdirs.find(dir)
    parent.subdirs.remove_at(i)
    self.removed_dir.emit(p)
    #emit_signal("removed_dir", p)
    return true


#func remove_recursive(p: FSPath) -> bool:
    #return false


## get a list of files in a directory
##
## @param p: Non null path to the directory to read.
## @return: (Array[FSPath]) an array of FSPaths to all directories contained in p.
func read_dirs_in_dir(p: FSPath) -> Array:
    var dir: FSDir = self._get_dir(p)
    if dir == null:
        return []
    
    return dir.subdirs.map(func (sd): return sd.get_path())


## Take a path, which may contain "." and ".." and return an absolute path
## pointing to the same location.
## Right now, works only for directories and not files.
## We would need self._get_file to be implemented to have it work for files.
##
## @param p: Non null path to simplify.
## @return: simplified FSPath if found, null if path did not exist.
func reduce_path(p: FSPath) -> FSPath:
    var loc: FSDir = self._get_dir(p)
    if loc == null:
        return null
    return loc.get_path()
    

func contains_type(p: FSPath) -> FSManager.filetype:
    if self.contains_dir(p):
        return self.filetype.DIR
    if self.contains_file(p):
        return self.filetype.FILE
    return self.filetype.NULL
