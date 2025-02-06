class_name ProcessRmdir
extends GVProcess

func run() -> int:
    var args: PackedStringArray = self.vargs.slice(1)
    match Array(args):
        []:
            self.stdout.write("rmdir: missing operand\n")
            return 1
        [var name]:
            var qualified: FSPath = self.cwd.compose(FSPath.new(name.split("/")))
            if self.fs_man.contains_dir(qualified):
                if self.fs_man.remove_dir(qualified):
                    return 0
                else:
                    self.stdout.write("rmdir: failed to remove '%s': Directory not empty\n" % name)
            elif self.fs_man.contains_file(qualified):
                self.stdout.write("rmdir: failed to remove '%s': Not a directory\n" % name)
            else:
                self.stdout.write("rmdir: failed to remove '%s': No such file or directory\n" % name)
        _:
            var some_worked: bool = false
            for name in args:
                var qualified: FSPath = self.cwd.compose(FSPath.new(name.split("/")))
                if self.fs_man.contains_dir(qualified):
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
