class_name ProcessLs
extends GVProcess


func run() -> int:
    var args: PackedStringArray = self.vargs.slice(1)
    match Array(args):
        []:
            # TODO: update for files
            for path in self.fs_man.read_dirs_in_dir(self.cwd):
                var strpath: String = path.last()
                if not strpath.begins_with("."):
                    self.stdout.write(strpath + "\n")
        ["-a"]:
            for path in self.fs_man.read_dirs_in_dir(self.cwd):
                var strpath: String = path.last().as_string(false)
                self.stdout.write(strpath + "\n")
        ["-a", ..]:
            self.stdout.write("Not implemented yet\n")
            return 1
        [..]:
            self.stdout.write("Not implemented yet\n")
            return 1
    return 0
