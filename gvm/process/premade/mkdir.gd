class_name ProcessMkdir
extends GVProcess


func run() -> int:
    var args: PackedStringArray = self.vargs.slice(1)
    var arguments: PackedStringArray = []
    var f_recur: bool = false
    
    for string in args:
        if string.begins_with("-"):
            if string == "-p":
                f_recur = true
            elif len(string) > 1:
                # TODO: technically this could print the wrong thing
                self.stdout.write("mkdir: invalid option -- '%s'\n" % string[1])
            else:
                arguments.push_back(string)
        else:
            arguments.push_back(string)

    var dirmaker: Callable
    if f_recur:
        dirmaker = self.make_dirs_recur
    else:
        dirmaker = self.make_a_dir
    
    if len(arguments) == 0:
        self.stdout.write("mkdir: missing operand\n")
        return 1
    else:
        var some_worked: bool = false
        for name in arguments:
            if dirmaker.call(name) == 0:
                some_worked = true
        if some_worked:
            return 0
    return 1


func make_a_dir(name: String) -> int:
    var path: FSPath = self.cwd.as_cwd(name)
    var real_ancestor: FSPath = self.fs_man.real_ancestry(path)
    var path_parent = path.base()
    
    if self.fs_man.contains_path(path):
        self.stdout.write("mkdir: cannot create directory ‘%s’: File exists\n" % name)
    elif self.fs_man.contains_type(real_ancestor) == FSManager.filetype.FILE:
        self.stdout.write("mkdir: cannot create directory ‘%s’: Not a directory\n" % name)
    elif not self.fs_man.contains_dir(path_parent):
        self.stdout.write("mkdir: cannot create directory ‘%s’: No such file or directory\n" % name) 
    elif self.fs_man.reduce_path(path_parent).as_string() != self.fs_man.reduce_path(real_ancestor).as_string():
        self.stdout.write("mkdir: cannot create directory ‘%s’: No such file or directory\n" % name)
    else:
        assert(self.fs_man.create_dir(path), "directory should have been created?")
        return 0
    return 1


func make_dirs_recur(name: String) -> int:
    var path: FSPath = self.cwd.as_cwd(name)
    var real_ancestor: FSPath = self.fs_man.real_ancestry(path)
    
    if self.fs_man.contains_path(path):
        self.stdout.write("mkdir: cannot create directory ‘%s’: File exists\n" % name)
    elif self.fs_man.contains_type(real_ancestor) == FSManager.filetype.FILE:
        self.stdout.write("mkdir: cannot create directory ‘%s’: Not a directory\n" % name)
    else:
        self._make_dirs_recur_unchecked(path, real_ancestor)
        return 0
    return 1


func _make_dirs_recur_unchecked(target: FSPath, ancestor: FSPath) -> void:
    if target.as_string() == ancestor.as_string():
        return
    
    var parent: FSPath = target.base()
    if self.fs_man.contains_dir(target):
        self._make_dirs_recur_unchecked(parent, ancestor)
    elif self.fs_man.contains_dir(parent):
        self.fs_man.create_dir(target)
        self._make_dirs_recur_unchecked(parent, ancestor)
    else:
        self._make_dirs_recur_unchecked(parent, ancestor)
        # Sometimes it was there all along but was not a valid pathname
        if not self.fs_man.contains_dir(target):
            self.fs_man.create_dir(target)
