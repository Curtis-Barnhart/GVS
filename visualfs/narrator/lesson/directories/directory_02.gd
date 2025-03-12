extends "res://visualfs/narrator/lesson/checkpoint.gd"

const UtilString = GVSClassLoader.shared.Strings
const FileTree = GVSClassLoader.visual.FileTree
const Path = GVSClassLoader.gvm.filesystem.Path

var _file_tree: FileTree


func start() -> void:            
    self._file_tree = self._viewport.node_from_scene("FileTree")
    self._file_tree.file_clicked.connect(self.directory_clicked)
    self._next_button.pressed.connect(self.finish)
    
    self._text_display.text = UtilString.make_article(
        [
            "Finding Files... the Smart Way",
            [
                "Okay, you've done this a few times now,",
                "so this next time, you'll work a little bit more on your own.",
                "Your starting position is the same this time,",
                "and the route to your destination is to go to",
                "'directory0', then 'subdirectory1', and lastly to 'file0'.",
                "This section will be completed as soon as you select",
                "your destination file.",
            ],
        ]
    )
    
    self._fs_man.create_dir(Path.new(["directory0", "subdirectory0"]))
    self._fs_man.create_dir(Path.new(["directory0", "subdirectory1"]))
    await GVSGlobals.wait(2)
    self._fs_man.create_file(Path.new(["directory0", "subdirectory0", "file0"]))
    self._fs_man.create_file(Path.new(["directory0", "subdirectory0", "file1"]))
    self._fs_man.create_file(Path.new(["directory0", "subdirectory1", "file0"]))
    self._fs_man.create_file(Path.new(["directory0", "subdirectory1", "file1"]))
    await GVSGlobals.wait(2)


func directory_clicked(file_path: Path) -> void:
    if file_path.as_string() == "/directory0":
        self._file_tree.file_clicked.disconnect(self.directory_clicked)
        self._file_tree.file_clicked.connect(self.next_directory_clicked)
        self._file_tree.highlight_path(Path.ROOT, file_path)


func next_directory_clicked(file_path: Path) -> void:
    if file_path.as_string() == "/directory0/subdirectory1":
        self._file_tree.file_clicked.disconnect(self.next_directory_clicked)
        self._file_tree.file_clicked.connect(self.file_clicked)
        self._file_tree.highlight_path(Path.ROOT, file_path)


func file_clicked(file_path: Path) -> void:
    if file_path.as_string() == "/directory0/subdirectory1/file0":
        self._file_tree.file_clicked.disconnect(self.file_clicked)
        self._file_tree.highlight_path(Path.ROOT, file_path)
        self._next_button.disabled = false


func finish() -> void:
    self._file_tree.highlight_path(Path.ROOT, Path.ROOT)
    self.completed.emit(
        preload("res://visualfs/narrator/lesson/directories/directory_03.gd").new(
            self._fs_man, self._next_button, self._text_display, self._viewport
        )
    )
    assert(
        self.get_reference_count() == 1,
        "Not all references to file_05 removed before checkpoint exit."
    )
