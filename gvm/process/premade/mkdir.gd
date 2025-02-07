class_name ProcessMkdir
extends GVProcess

func run() -> int:
    var args: PackedStringArray = self.vargs.slice(1)
    match Array(args):
        []:
            self.stdout.write("mkdir: missing operand\n")
            return 1
        _:
            var some_worked: bool = false
            for name in args:
                if not self.fs_man.create_dir(self.cwd.compose(FSPath.new(name.split("/")))):
                    self.stdout.write("mkdir: cannot create directory %s\n" % name)
                else:
                    some_worked = true
            if some_worked:
                return 0
    return 1
