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
func before_each() -> void:
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


func test_contains_dir() -> void:
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


func test_contains_file() -> void:
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


func test_create_dir() -> void:
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


func test_create_dir_bad() -> void:
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


func test_remove_dir() -> void:
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
    self.assert_false(self._man.contains_dir(Path.new(["new_dir", "new_dir"])))

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
    self.assert_false(self._man.contains_dir(Path.new(["new_dir"])))


func test_remove_dir_bad() -> void:
    self.assert_true(self._man.create_dir(Path.new(["nested"])))
    self.assert_true(self._man.create_dir(Path.new(["nested", "nested"])))

    self.watch_signals(self._man)
    var swatch: SignalWatcher = self._signal_watcher

    self.assert_false(self._man.remove_dir(Path.new([])))
    self.assert_signal_emit_count(self._man, "removed_dir", 0,
        "On bad dir removal `/` (root), signal `removed_dir` was emitted."
    )

    self.assert_false(self._man.remove_dir(Path.new(["aaaa"])))
    self.assert_signal_emit_count(self._man, "removed_dir", 0,
        "On bad dir removal `/aaaa` (does not exist), signal `removed_dir` was emitted."
    )

    self.assert_false(self._man.remove_dir(Path.new(["two"])))
    self.assert_signal_emit_count(self._man, "removed_dir", 0,
        "On bad dir removal `/two` (nonempty), signal `removed_dir` was emitted."
    )

    self.assert_false(self._man.remove_dir(Path.new(["three", "four"])))
    self.assert_signal_emit_count(self._man, "removed_dir", 0,
        "On bad dir removal `/three/four` (nonempty), signal `removed_dir` was emitted."
    )

    self.assert_false(self._man.remove_dir(Path.new(["nested"])))
    self.assert_signal_emit_count(self._man, "removed_dir", 0,
        "On bad dir removal `/nested` (nonempty), signal `removed_dir` was emitted."
    )

    self.assert_false(self._man.remove_dir(Path.new(["nested", "aaa"])))
    self.assert_signal_emit_count(self._man, "removed_dir", 0,
        "On bad dir removal `/nested/aaa` (does not exist), signal `removed_dir` was emitted."
    )


func test_create_file() -> void:
    var file_count: int = 0
    self.watch_signals(self._man)
    var swatch: SignalWatcher = self._signal_watcher

    self.assert_true(self._man.create_file(Path.new(["new_file"])))
    file_count += 1
    self.assert_signal_emit_count(self._man, "created_file", file_count,
        "On file creation, signal `created_file` was not emitted exactly once."
    )
    self.assert_eq(
        (swatch.get_signal_parameters(self._man, "created_file")[0] as Path).as_string(),
        "/new_file",
        "On file '/new_file' creation, signal was emitted with wrong path."
    )

    self.assert_true(self._man.create_file(Path.new(["three", "four", "new_file"])))
    file_count += 1
    self.assert_signal_emit_count(self._man, "created_file", file_count,
        "On file creation, signal `created_file` was not emitted exactly once."
    )
    self.assert_eq(
        (swatch.get_signal_parameters(self._man, "created_file")[0] as Path).as_string(),
        "/three/four/new_file",
        "On file '/three/four/new_file' creation, signal was emitted with wrong path."
    )

    self.assert_true(self._man.contains_file(Path.new(["three", "four", "new_file"])))
    self.assert_true(self._man.contains_file(Path.new(["new_file"])))


func test_create_file_bad() -> void:
    self.watch_signals(self._man)
    var swatch: SignalWatcher = self._signal_watcher

    self.assert_false(self._man.create_file(Path.new([])))
    self.assert_signal_emit_count(self._man, "created_file", 0,
        "Signal `created_file` emitted on bad file creation `/` (is root directory)."
    )

    self.assert_false(self._man.create_file(Path.new(["two"])))
    self.assert_signal_emit_count(self._man, "created_file", 0,
        "Signal `created_file` emitted on bad file creation `/two` (is a directory)."
    )

    self.assert_false(self._man.create_file(Path.new(["two", "file0"])))
    self.assert_signal_emit_count(self._man, "created_file", 0,
        "Signal `created_file` emitted on bad file creation '/two/file0' (already exists)."
    )

    self.assert_false(self._man.create_file(Path.new(["three", "four"])))
    self.assert_signal_emit_count(self._man, "created_file", 0,
        "Signal `created_file` emitted on bad file creation `/three/four` (is a directory)."
    )

    self.assert_false(self._man.create_file(Path.new(["three", "four", "five", "six", "seven"])))
    self.assert_signal_emit_count(self._man, "created_file", 0,
        "Signal `created_file` emitted on bad file creation '/three/four/five/six/seven' (no such directory exists)."
    )


func test_remove_file() -> void:
    self.watch_signals(self._man)
    var swatch: SignalWatcher = self._signal_watcher
    var file_count: int = 0

    self.assert_true(self._man.remove_file(Path.new(["two", "file0"])))
    file_count += 1
    self.assert_signal_emit_count(self._man, "removed_file", file_count,
        "On file removal, signal `removed_file` was not emitted exactly once."
    )
    self.assert_eq(
        (swatch.get_signal_parameters(self._man, "removed_file")[0] as Path).as_string(),
        "/two/file0",
        "On file '/two/file0' removal, signal was emitted with wrong path."
    )
    self.assert_false(self._man.contains_file(Path.new(["two", "file0"])))

    self.assert_true(self._man.remove_file(Path.new(["three", "file1"])))
    file_count += 1
    self.assert_signal_emit_count(self._man, "removed_file", file_count,
        "On file removal, signal `removed_file` was not emitted exactly once."
    )
    self.assert_eq(
        (swatch.get_signal_parameters(self._man, "removed_file")[0] as Path).as_string(),
        "/three/file1",
        "On file '/three/file1' removal, signal was emitted with wrong path."
    )
    self.assert_false(self._man.contains_file(Path.new(["three", "file1"])))

    self.assert_true(self._man.remove_file(Path.new(["three", "file2"])))
    file_count += 1
    self.assert_signal_emit_count(self._man, "removed_file", file_count,
        "On file removal, signal `removed_file` was not emitted exactly once."
    )
    self.assert_eq(
        (swatch.get_signal_parameters(self._man, "removed_file")[0] as Path).as_string(),
        "/three/file2",
        "On file '/three/file2' removal, signal was emitted with wrong path."
    )
    self.assert_false(self._man.contains_file(Path.new(["three", "file2"])))

    self.assert_true(self._man.remove_file(Path.new(["three", "four", "file3"])))
    file_count += 1
    self.assert_signal_emit_count(self._man, "removed_file", file_count,
        "On file removal, signal `removed_file` was not emitted exactly once."
    )
    self.assert_eq(
        (swatch.get_signal_parameters(self._man, "removed_file")[0] as Path).as_string(),
        "/three/four/file3",
        "On file '/three/four/file3' removal, signal was emitted with wrong path."
    )
    self.assert_false(self._man.contains_file(Path.new(["three", "four", "file3"])))


func test_remove_file_bad() -> void:
    self.watch_signals(self._man)
    var swatch: SignalWatcher = self._signal_watcher

    self.assert_false(self._man.remove_file(Path.new([])))
    self.assert_signal_emit_count(self._man, "removed_file", 0,
        "On bad file removal `/` (root), signal `removed_file` was emitted."
    )

    self.assert_false(self._man.remove_file(Path.new(["aaaa"])))
    self.assert_signal_emit_count(self._man, "removed_file", 0,
        "On bad file removal `/aaaa` (does not exist), signal `removed_file` was emitted."
    )

    self.assert_false(self._man.remove_file(Path.new(["two"])))
    self.assert_signal_emit_count(self._man, "removed_file", 0,
        "On bad file removal `/two` (is a directory), signal `removed_file` was emitted."
    )

    self.assert_false(self._man.remove_file(Path.new(["three", "four"])))
    self.assert_signal_emit_count(self._man, "removed_file", 0,
        "On bad file removal `/three/four` (is a directory), signal `removed_file` was emitted."
    )

    self.assert_false(self._man.remove_file(Path.new(["three", "four", "five"])))
    self.assert_signal_emit_count(self._man, "removed_file", 0,
        "On bad file removal `/three/four/five` (does not exist), signal `removed_file` was emitted."
    )


func test_remove_recursive_success() -> void:
    self.assert_true(
        self._man.remove_recursive(Path.new(["three"])),
        "Directory '/three' should be removed successfully."
    )
    self.assert_false(
        self._man.contains_dir(Path.new(["three"])),
        "'/three' should no longer exist."
    )


func test_remove_recursive_failure() -> void:
    self.assert_false(
        self._man.remove_recursive(Path.ROOT),
        "Attempting to remove root directory should fail."
    )
    self.assert_false(
        self._man.remove_recursive(Path.new(["three", "unknown"])),
        "Attempting to remove nonexistent directory '/three/unknown' should fail."
    )
    # Ensure that existing directories were not mistakenly removed
    self.assert_true(
        self._man.contains_dir(Path.new(["three"]))
    )
    self.assert_true(
        self._man.contains_file(Path.new(["three", "file1"]))
    )


# This test forces the order to be the same, which is not strictly required.
# Maybe make the test compare without order later when I have the time?
func test_read_dirs_in_dir() -> void:
    self.assert_eq(
        self._man \
            .read_dirs_in_dir(Path.new([])) \
            .map(func(p: Path) -> String: return p.as_string()),
        ["/two", "/three", "/.", "/.."],
        "Root directory should contain '.', '..', 'two', and 'three'."
    )
    
    self.assert_eq(
        self._man \
            .read_dirs_in_dir(Path.new(["three"])) \
            .map(func(p: Path) -> String: return p.as_string()),
        ["/three/four", "/three/.", "/three/.."],
        "Directory '/three' should contain '.', '..', and 'four'."
    )
    
    self.assert_eq(
        self._man \
            .read_dirs_in_dir(Path.new(["three", "four"])) \
            .map(func(p: Path) -> String: return p.as_string()),
        ["/three/four/.", "/three/four/.."],
        "Directory '/three/four' should only contain '.' and '..'."
    )


func test_read_files_in_dir() -> void:
    self.assert_eq(
        self._man \
            .read_files_in_dir(Path.new(["two"])) \
            .map(func(p: Path) -> String: return p.as_string()),
        ["/two/file0"],
        "Directory '/two' should contain 'file0'."
    )
    
    self.assert_eq(
        self._man \
            .read_files_in_dir(Path.new(["three"])) \
            .map(func(p: Path) -> String: return p.as_string()),
        ["/three/file1", "/three/file2"],
        "Directory '/three' should contain 'file1' and 'file2'."
    )
    
    self.assert_eq(
        self._man \
            .read_files_in_dir(Path.new(["three", "four"])) \
            .map(func(p: Path) -> String: return p.as_string()),
        ["/three/four/file3", "/three/four/file4", "/three/four/file5"],
        "Directory '/three/four' should contain 'file3', 'file4', and 'file5'."
    )


func test_reduce_path() -> void:
    self.assert_eq(
        self._man.reduce_path(Path.new([".", "two", "..", "three"])).as_string(),
        "/three",
        "Path '/./two/../three' should reduce to '/three'."
    )
    
    self.assert_eq(
        self._man.reduce_path(Path.new(["three", "four", ".."])).as_string(),
        "/three",
        "Path '/three/four/..' should reduce to '/three'."
    )
    
    self.assert_eq(
        self._man.reduce_path(Path.new(["three", "four", ".", ".", "."])).as_string(),
        "/three/four",
        "Path '/three/four/././.' should reduce to '/three/four'."
    )
    
    self.assert_eq(
        self._man.reduce_path(Path.new(["three", "four", "file3"])).as_string(),
        "/three/four/file3",
        "Path '/three/four/file3' should reduce to '/three/four/file3'"
    )

    self.assert_eq(
        self._man.reduce_path(Path.new(["..", "..", ".."])).as_string(),
        "/",
        "Path '/../../..' should reduce to '/'."
    )


func test_reduce_path_bad() -> void:
    self.assert_null(
        self._man.reduce_path(Path.new(["unknown"])),
        "Nonexistent path '/unknown' should return null."
    )
    
    self.assert_null(
        self._man.reduce_path(Path.new(["three/unknown/.."])),
        "Nonexistent path '/three/unknown/..' should return null."
    )
        
    self.assert_null(
        self._man.reduce_path(Path.new(["three", "file1", ".."])),
        "Path '/three/file1/..' should return null since file1 is not a directory."
    )
    
    self.assert_null(
        self._man.reduce_path(Path.new(["three", "file2", "..", "file1"])),
        "Path '/three/file2/../file1' should return null since file2 is not a directory."
    )


func test_real_ancestry() -> void:
    self.assert_eq(
        self._man.real_ancestry(Path.new(["three", "four", "unknown"])).as_string(),
        "/three/four",
        "Nonexistent path '/three/four/unknown' should resolve to '/three/four'."
    )
    
    self.assert_eq(
        self._man.real_ancestry(Path.new(["two", "file0", "ghost"])).as_string(),
        "/two/file0",
        "Nonexistent path '/two/file0/ghost' should resolve to '/two/file0'."
    )
    
    self.assert_eq(
        self._man.real_ancestry(Path.new(["nowhere", "random"])).as_string(),
        "/",
        "Nonexistent path '/nowhere/random' should resolve to '/'."
    )
