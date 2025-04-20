# What's cool about this guy is that he is guaranteed to send signals when
# anything changes, and he will also do it via signals and take care of all
# of the references to file/dir structures.
# He is also guaranteed to never contain loops in the underlying file structure.

extends RefCounted

const Directory = GVSClassLoader.gvm.filesystem.Directory
const File = GVSClassLoader.gvm.filesystem.File
const Path = GVSClassLoader.gvm.filesystem.Path
const FSManager = GVSClassLoader.gvm.filesystem.Manager


## path is guaranteed to be in simplest form
signal created_dir(path: Path)
signal created_file(path: Path)
signal removed_dir(path: Path)
signal removed_file(path: Path)

# Guaranteed non null
var _root: Directory = Directory.new("", null)

enum filetype { FILE, DIR, NULL }


func _init() -> void:
    # This creates a cyclic references that will never be deleted because of reference counting.
    # This must be manually deleted in func _notification before this object is deconstructed.
    self._root.parent = self._root


# Removes cyclic reference in self._root to itself so that it can be freed
func _notification(what: int) -> void:
    if what == NOTIFICATION_PREDELETE:
        # This would be self._root.parent but for this bug(?):
        # https://github.com/godotengine/godot/issues/6784
        # https://github.com/godotengine/godot/issues/80834
        # self is null, buf data inside it can still be accessed.
        # I am genuinely not sure what the intended behavior is,
        # but my best guess says that this is a relatively
        # safe/stable thing to do
        # Maybe it's so that you can't create a hanging pointer
        # in the destructor?
        _root.parent = null


func contains_file(p: Path) -> bool:
    return self._root.get_file(p) != null


func contains_dir(p: Path) -> bool:
    return self._get_dir(p) != null


func contains_path(p: Path) -> bool:
    return self.contains_file(p) or self.contains_dir(p)


## Get a Directory object by path, if it exists.
##
## @param p: Non null path to the directory to get.
## @return: the Directory object located by path p, or null if it does not exist.
func _get_dir(p: Path) -> Directory:
    if p.degen():
        return self._root
    return self._root.get_dir(p)


func _get_file(p: Path) -> File:
    return self._root.get_file(p)


## Create a single directory as a subdirectory of an existing directory,
## then emits a single with a path to the created dictionary.
##
## @param p: Non null path to the directory to create.
## @return: true if directory was created, false otherwise.
func create_dir(p: Path) -> bool:
    var contain_path: Path = p.base()
    var new_dir_name: String = p.last()

    if new_dir_name == "":
        return false

    # Only create the new directory if the claimed parent is a real directory
    # and that parent does not already contain a directory with the same name.
    var contain_dir: Directory = self._get_dir(contain_path)
    if contain_dir == null:
        return false
    if new_dir_name in self.read_all_in_dir(contain_path)       \
                           .map(func (path: Path) -> String: return path.last()):
        return false

    p = contain_dir.get_path().extend(new_dir_name)
    contain_dir.subdirs.push_back(Directory.new(new_dir_name, contain_dir))
    self.created_dir.emit(p)
    return true


func create_file(p: Path) -> bool:
    var contain_path: Path = p.base()
    var new_file_name: String = p.last()

    if new_file_name == "":
        return false

    # Only create the new file if the claimed parent is a real directory
    # and that parent does not already contain anything with the same name.
    var contain_dir: Directory = self._get_dir(contain_path)
    if contain_dir == null:
        return false
    if new_file_name in self.read_all_in_dir(contain_path) \
                            .map(func (path: Path) -> String: return path.last()):
        return false

    p = contain_dir.get_path().extend(new_file_name)
    contain_dir.files.push_back(File.new(new_file_name, contain_dir))
    self.created_file.emit(p)
    return true


# if the read/write file interface ever changes,
# be sure to update(?) the warning surpression in fs_file
# that warns that the private var _contents is never used.
func write_file(p: Path, text: String) -> bool:
    var file: File = self._get_file(p)
    if file != null:
        file._contents = text
        return true
    return false


## I have been troubled as to whether this should handle files not existing
## differently. Unfortunately, Godot does not support nullable values.
func read_file(p: Path) -> String:
    var file: File = self._get_file(p)
    if file != null:
        return file._contents
    return ""


## Remove a single empty directory that is not the root directory.
##
## @param p: Non null path to the directory to remove.
## @return: true if directory was removed, false otherwise.
func remove_dir(p: Path) -> bool:
    var dir: Directory = self._get_dir(p)
    if (
        dir == self._root
        or dir == null
        or not dir.is_empty()
    ):
        return false

    p = self.reduce_path(p)
    var parent: Directory = dir.parent
    # TODO: I'm sure there's a method to remove it directly?
    var i: int = parent.subdirs.find(dir)
    parent.subdirs.remove_at(i)
    self.removed_dir.emit(p)
    return true


## Removes a directory and all its subdirectories and files from the fs.
##
## @param p: Path to the directory to recursively remove.
## @return: true if the directory could be removed, else false.
func remove_recursive(p: Path) -> bool:
    var dir: Directory = self._get_dir(p)
    if (dir == self._root or dir == null):
        return false

    for sub: Path in self.read_files_in_dir(p):
        self.remove_file(sub)

    for sub: Path in self.read_dirs_in_dir(p).slice(0, -2):
        self.remove_recursive(sub)

    self.remove_dir(p)
    return true


func remove_file(p: Path) -> bool:
    var file: File = self._get_file(p)
    if file == null:
        return false

    var parent: Directory = file._parent
    var i: int = parent.files.find(file)
    parent.files.remove_at(i)
    self.removed_file.emit(parent.get_path().extend(p.last()))
    return true


## get a list of directories in a directory
##
## @param p: Non null path to the directory to read.
## @return: (Array[Path]) an array of FSPaths to all directories contained in p.
func read_dirs_in_dir(p: Path) -> Array:
    var dir: Directory = self._get_dir(p)
    if dir == null:
        return []

    return dir.subdirs.map(
        func (sd: Directory) -> Path:
            return sd.get_path()
    ) + [
        dir.get_path().extend("."),
        dir.get_path().extend("..")
    ]


## get a list of files in a directory
##
## @param p: Non null path to the directory to read.
## @return: (Array[Path]) an array of FSPaths to all files contained in p.
func read_files_in_dir(p: Path) -> Array:
    var dir: Directory = self._get_dir(p)
    if dir == null:
        return []

    return dir.files.map(func (f: File) -> Path: return f.get_path())


## get a list of files and directories in a directory
##
## @param p: Non null path to the directory to read.
## @return: (Array[Path]) an array of FSPaths to all directories
##          and files contained in p.
func read_all_in_dir(p: Path) -> Array:
    return self.read_dirs_in_dir(p) + self.read_files_in_dir(p)


## Take a path, which may contain "." and ".." and return an absolute path
## pointing to the same location.
##
## @param p: Non null path to simplify.
## @return: simplified Path if found, null if path did not exist.
func reduce_path(p: Path) -> Path:
    var loc_dir: Directory = self._get_dir(p)
    if loc_dir != null:
        return loc_dir.get_path()
    var loc_file: File = self._get_file(p)
    if loc_file != null:
        return loc_file.get_path()
    return null


## Better contains that tells you what type of thing a path points to is.
##
## @param p: The path to test.
## @return: enum DIR if directory, FILE if file, NULL otherwise.
func contains_type(p: Path) -> FSManager.filetype:
    if self.contains_dir(p):
        return self.filetype.DIR
    if self.contains_file(p):
        return self.filetype.FILE
    return self.filetype.NULL


## If you have a nonexistant path, give it here and you'll get back the longest
## matching existing path (in simplest form).
##
## TODO: This is currently O(n^2) and could be O(n)...
##
## @param p: path to shorten until it is real.
## @return: closest real version of that path.
func real_ancestry(p: Path) -> Path:
    while not self.contains_path(p):
        p = p.base()
    return p


## Given two Paths, return a relative path from the second to the first.
## The two paths need not be simplified,
## and the returned path will be sipmlified.[br][br]
##
## [param dst]: Destination path.[br]
## [param src]: Source path.[br]
## [param return]: Relative path from [code]src[/code] to [code]dst[/code].
func relative_to(dst: Path, src: Path) -> Path:
    assert(dst != null)
    assert(src != null)

    dst = self.reduce_path(dst)
    src = self.reduce_path(src)
    if dst == null or src == null:
        return null

    var common_base: Path = dst.common_with(src)
    return Path.new(
        GStreams.Repeat("..") \
                .take(src.size() - common_base.size()) \
                .as_array()
    ).compose(dst.slice(common_base.size()))


## Takes two paths and returns information about where they begin
## to diverge from one another and where they go on from there.[br]
## Both paths must exist in the file system.
## The first path must be acyclic (accesses no parent directories).[br][br]
##
## [param acyclic]: Acyclic path (contains no "..")[br]
## [param p2]: A path to compare against [code]acyclic[/code][br]
## [param return]: An array of three paths.
##      The first path is the longest subpath of [code]p2[/code] that points
##      to a location which is an ancestor of [code]acyclic[/code].
##      The second path is that ancestor of [code]acyclic[/code].
##      The third path is the remaining part of [code]p2[/code].
func path_branches_abs(acyclic: Path, p2: Path, skip: int = 0) -> Array[Path]:
    assert(self.contains_path(acyclic))
    assert(
        self.contains_path(p2),
        "filesystem does not contain %s" % p2.as_string()
    )
    
    var acyclic_stops: Dictionary[String, int] = {}
    
    for p_ar: Array in acyclic.all_slices().enumerate():
        acyclic_stops.set(
            self.reduce_path(p_ar[1] as Path).as_string(), p_ar[0]
        )
    
    var branch: Path = null
    var longest_match: int = -1
    for p: Path in p2.all_slices():
        var r: String = self.reduce_path(p).as_string()
        if (
            acyclic_stops.has(r)
            and acyclic_stops[r] >= longest_match
            and skip < 1
        ):
            branch = p
            longest_match = acyclic_stops[r]
        skip -= 1

    return [
        branch,
        acyclic.slice(acyclic_stops[self.reduce_path(branch).as_string()]),
        p2.slice(branch.size())
    ]
