class_name ProcessLs
extends GVProcess


func run() -> int:
    var args: PackedStringArray = self.vargs.slice(1)
    var arguments: PackedStringArray = []
    var f_hidden: bool = false
    
    for string in args:
        if string.begins_with("-"):
            if string == "-a":
                f_hidden = true
            elif len(string) > 1:
                self.stdout.write("ls: invalid option -- '%s'" % string[1])
        else:
            arguments.push_back(string)
    
    var failure: int = 0
    match len(arguments):
        0:
            return self.analyze_path(self.cwd.as_string(), f_hidden)
        1:
            return self.analyze_path(arguments[0], f_hidden)
        _:
            for arg in arguments:
                self.stdout.write("%s:\n" % arg)
                if self.analyze_path(arg, f_hidden) == 1:
                    self.failure = 1
    
    return failure


func analyze_path(p_str: String, f_hidden: bool) -> int:
    # Path is absolute if it started with "/", otherwise it starts at cwd
    var path: FSPath
    if p_str.begins_with("/"):
        path = FSPath.new(p_str.split("/", false))
    else:
        path = self.cwd.compose(FSPath.new(p_str.split("/", false)))

    if self.fs_man.contains_path(path):
        if self.fs_man.contains_dir(path):
            for child in self.fs_man.read_dirs_in_dir(path):
                var str_child: String = child.last()
                if not f_hidden:
                    if not str_child.begins_with("."):
                        self.stdout.write(str_child + "\n")
                else:
                    self.stdout.write(str_child + "\n")
        else:
            self.stdout.write(p_str + "\n")
        return 0
    
    self.stdout.write("ls: cannot access '%s': No such file or directory\n" % p_str)
    return 1
