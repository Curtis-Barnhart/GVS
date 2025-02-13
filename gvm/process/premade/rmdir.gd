extends "res://gvm/process/process.gd"

## Defined in parent class
#const ClassLoader = preload("res://gvs_class_loader.gd")
#const Path = ClassLoader.gvm.filesystem.Path

func run() -> int:
    var args: PackedStringArray = self.vargs.slice(1)
    match Array(args):
        []:
            self.stdout.write("rmdir: missing operand\n")
            return 1
        _:
            var some_worked: bool = false
            for name in args:
                var qualified: Path = self.cwd.as_cwd(name)
                if self.fs_man.contains_dir(qualified):
                    if self.cwd.as_string() == self.fs_man.reduce_path(qualified).as_string():
                        self.stdout.write("rmdir: failed to remove '%s': Cannot remove current working directory\n" % name)
                    else:
                        if self.fs_man.remove_dir(qualified):
                            some_worked = true
                        else:
                            self.stdout.write("rmdir: failed to remove '%s': Directory not empty\n" % name)
                elif self.fs_man.contains_file(qualified):
                    self.stdout.write("rmdir: failed to remove '%s': Not a directory\n" % name)
                else:
                    self.stdout.write("rmdir: failed to remove '%s': No such file or directory\n" % name)
            if some_worked:
                return 0
    return 1
