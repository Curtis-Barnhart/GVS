extends GutTest

const Manager = GVSClassLoader.gvm.filesystem.Manager
const Path = GVSClassLoader.gvm.filesystem.Path
const SignalWatcher = preload("res://addons/gut/signal_watcher.gd")

var _man: Manager


#                     root
#        .-------------^------.
#       two                 three
#        ^        .-----.-----^----.
#      file0    file1 file2       four
#                             .----.^------.
#                           file3 file4 file5
func before_each():
    self._man = Manager.new()
    self._man.create_dir(Path.new(["two"]))
    self._man.create_dir(Path.new(["three"]))
    self._man.create_dir(Path.new(["three", "four"]))
    self._man.create_file(Path.new(["two", "file0"]))
    self._man.create_file(Path.new(["three", "file1"]))
    self._man.create_file(Path.new(["three", "file2"]))
    self._man.create_file(Path.new(["three", "four", "file3"]))
    self._man.create_file(Path.new(["three", "four",  "file4"]))
    self._man.create_file(Path.new(["three", "four",  "file5"]))


func test_contains_dir():
    self.assert_true(self._man.contains_dir(Path.new([])))
    self.assert_true(self._man.contains_dir(Path.new(["two"])))
    self.assert_true(self._man.contains_dir(Path.new(["three"])))
    self.assert_true(self._man.contains_dir(Path.new(["three", "four"])))

    self.assert_false(self._man.contains_dir(Path.new(["four"])))

    self.assert_false(self._man.contains_dir(Path.new(["two", "file0"])))
    self.assert_false(self._man.contains_dir(Path.new(["three", "file1"])))
    self.assert_false(self._man.contains_dir(Path.new(["three", "file2"])))
    self.assert_false(self._man.contains_dir(Path.new(["three", "four", "file3"])))
    self.assert_false(self._man.contains_dir(Path.new(["three", "four",  "file4"])))
    self.assert_false(self._man.contains_dir(Path.new(["three", "four",  "file5"])))


func test_contains_file():
    self.assert_false(self._man.contains_file(Path.new([])))
    self.assert_false(self._man.contains_file(Path.new(["two"])))
    self.assert_false(self._man.contains_file(Path.new(["three"])))
    self.assert_false(self._man.contains_file(Path.new(["three", "four"])))

    self.assert_true(self._man.contains_file(Path.new(["two", "file0"])))
    self.assert_true(self._man.contains_file(Path.new(["three", "file1"])))
    self.assert_true(self._man.contains_file(Path.new(["three", "file2"])))
    self.assert_true(self._man.contains_file(Path.new(["three", "four", "file3"])))
    self.assert_true(self._man.contains_file(Path.new(["three", "four",  "file4"])))
    self.assert_true(self._man.contains_file(Path.new(["three", "four",  "file5"])))

    self.assert_false(self._man.contains_file(Path.new(["file0"])))
    self.assert_false(self._man.contains_file(Path.new(["file1"])))
    self.assert_false(self._man.contains_file(Path.new(["file2"])))
    self.assert_false(self._man.contains_file(Path.new(["file3"])))
    self.assert_false(self._man.contains_file(Path.new(["file4"])))
    self.assert_false(self._man.contains_file(Path.new(["file5"])))


func test_create_dir():
    var dir_count: int = 0
    self.watch_signals(self._man)
    var swatch: SignalWatcher = self._signal_watcher
    
    self.assert_true(self._man.create_dir(Path.new(["new_dir"])))
    dir_count += 1
    self.assert_signal_emit_count(self._man, "created_dir", dir_count,
        "On dir creation, signal `created_dir` was not emitted exactly once."
    )
    self.assert_eq(
        (swatch.get_signal_parameters(self._man, "created_dir")[0] as Path).as_string(),
        "/new_dir",
        "On dir '/new_dir' creation, signal was emitted with wrong path."
    )
    
    self.assert_true(self._man.create_dir(Path.new(["new_dir", "new_dir"])))
    dir_count += 1
    self.assert_signal_emit_count(self._man, "created_dir", dir_count,
        "On dir creation, signal `created_dir` was not emitted exactly once."
    )
    self.assert_eq(
        (swatch.get_signal_parameters(self._man, "created_dir")[0] as Path).as_string(),
        "/new_dir/new_dir",
        "On dir '/new_dir/new_dir' creation, signal was emitted with wrong path."
    )
    
    self.assert_true(self._man.create_dir(Path.new(["three", "four", "new_dir"])))
    dir_count += 1
    self.assert_signal_emit_count(self._man, "created_dir", dir_count,
        "On dir creation, signal `created_dir` was not emitted exactly once."
    )
    self.assert_eq(
        (swatch.get_signal_parameters(self._man, "created_dir")[0] as Path).as_string(),
        "/three/four/new_dir",
        "On dir '/new_dir' creation, signal was emitted with wrong path."
    )

    self.assert_true(self._man.contains_dir(Path.new(["three", "four", "new_dir"])))
    self.assert_true(self._man.contains_dir(Path.new(["new_dir"])))
    self.assert_true(self._man.contains_dir(Path.new(["new_dir", "new_dir"])))


func test_create_dir_bad():
    self.watch_signals(self._man)
    var swatch: SignalWatcher = self._signal_watcher
    
    self.assert_false(self._man.create_dir(Path.new([])))
    self.assert_signal_emit_count(self._man, "created_dir", 0,
        "Signal `created_dir` emitted on bad dir creation '/'."
    )

    self.assert_false(self._man.create_dir(Path.new(["two"])))
    self.assert_signal_emit_count(self._man, "created_dir", 0,
        "Signal `created_dir` emitted on bad dir creation '/two'."
    )

    self.assert_false(self._man.create_dir(Path.new(["two", "file0"])))
    self.assert_signal_emit_count(self._man, "created_dir", 0,
        "Signal `created_dir` emitted on bad dir creation '/two/file0'."
    )
    self.assert_false(self._man.contains_dir(Path.new(["two", "file0"])))

    self.assert_false(self._man.create_dir(Path.new(["three", "four"])))
    self.assert_signal_emit_count(self._man, "created_dir", 0,
        "Signal `created_dir` emitted on bad dir creation '/three/four'."
    )

    self.assert_false(self._man.create_dir(Path.new(["three", "four", "five", "six", "seven"])))
    self.assert_signal_emit_count(self._man, "created_dir", 0,
        "Signal `created_dir` emitted on bad dir creation '/three/four/five/six/seven'."
    )
    self.assert_false(self._man.contains_dir(Path.new(["three", "four", "five", "six", "seven"])))


func test_remove_dir():
    self.assert_true(self._man.create_dir(Path.new(["new_dir"])))
    self.assert_true(self._man.create_dir(Path.new(["new_dir", "new_dir"])))

    self.watch_signals(self._man)
    var swatch: SignalWatcher = self._signal_watcher
    var dir_count: int = 0

    self.assert_true(self._man.remove_dir(Path.new(["new_dir", "new_dir"])))
    dir_count += 1
    self.assert_signal_emit_count(self._man, "removed_dir", dir_count,
        "On dir removal, signal `removed_dir` was not emitted exactly once."
    )
    self.assert_eq(
        (swatch.get_signal_parameters(self._man, "removed_dir")[0] as Path).as_string(),
        "/new_dir/new_dir",
        "On dir '/new_dir/new_dir' removal, signal was emitted with wrong path."
    )

    self.assert_true(self._man.remove_dir(Path.new(["new_dir"])))
    dir_count += 1
    self.assert_signal_emit_count(self._man, "removed_dir", dir_count,
        "On dir removal, signal `removed_dir` was not emitted exactly once."
    )
    self.assert_eq(
        (swatch.get_signal_parameters(self._man, "removed_dir")[0] as Path).as_string(),
        "/new_dir",
        "On dir '/new_dir' removal, signal was emitted with wrong path."
    )


func test_remove_dir_bad():
    self.assert_true(self._man.create_dir(Path.new(["nested"])))
    self.assert_true(self._man.create_dir(Path.new(["nested", "nested"])))

    self.watch_signals(self._man)
    var swatch: SignalWatcher = self._signal_watcher

    self.assert_false(self._man.remove_dir(Path.new([])))
    self.assert_signal_emit_count(self._man, "removed_dir", 0,
        "On bad dir removal `/` (root), signal `removed_dir` was emitted"
    )

    self.assert_false(self._man.remove_dir(Path.new(["aaaa"])))
    self.assert_signal_emit_count(self._man, "removed_dir", 0,
        "On bad dir removal `/aaaa` (does not exist), signal `removed_dir` was emitted"
    )

    self.assert_false(self._man.remove_dir(Path.new(["two"])))
    self.assert_signal_emit_count(self._man, "removed_dir", 0,
        "On bad dir removal `/two` (nonempty), signal `removed_dir` was emitted"
    )

    self.assert_false(self._man.remove_dir(Path.new(["three", "four"])))
    self.assert_signal_emit_count(self._man, "removed_dir", 0,
        "On bad dir removal `/three/four` (nonempty), signal `removed_dir` was emitted"
    )

    self.assert_false(self._man.remove_dir(Path.new(["nested"])))
    self.assert_signal_emit_count(self._man, "removed_dir", 0,
        "On bad dir removal `/nested` (nonempty), signal `removed_dir` was emitted"
    )

    self.assert_false(self._man.remove_dir(Path.new(["nested", "aaa"])))
    self.assert_signal_emit_count(self._man, "removed_dir", 0,
        "On bad dir removal `/nested/aaa` (does not exist), signal `removed_dir` was emitted"
    )


func test_create_file():
    pass


func test_create_file_bad():
    pass


func test_remove_file():
    pass


func test_remove_file_bad():
    pass
