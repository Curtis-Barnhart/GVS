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
                "Let's consider a more complicated example,",
                "one with another road in between you and your goal.",
                "This time, the first 'road' you'll need to take",
                "is called 'directory1'.",
                "'directory1' isn't a file - just like a highway or intersection",
                "it isn't a destination in and of itself,",
                "these intermediary places don't hold information like files do -",
                "they simply exist to help route you between different files.",
            ],
            [
                "After you click on 'directory1',",
                "you should see the red line update to show your 'route' so far.",
                "The next turn you'll make will be your destination,",
                "which is 'file1'.",
                "After you click on 'file1',",
                "you should see your 'route' update again,",
                "and you'll be able to complete this section.",
            ],
        ]
    )
    
    self._fs_man.create_dir(Path.new(["directory0"]))
    self._fs_man.create_dir(Path.new(["directory1"]))
    await GVSGlobals.wait(2)
    self._fs_man.create_file(Path.new(["directory0", "file0"]))
    self._fs_man.create_file(Path.new(["directory0", "file1"]))
    self._fs_man.create_file(Path.new(["directory1", "file0"]))
    self._fs_man.create_file(Path.new(["directory1", "file1"]))
    await GVSGlobals.wait(2)


func directory_clicked(file_path: Path) -> void:
    if file_path.as_string() == "/directory1":
        self._file_tree.file_clicked.disconnect(self.directory_clicked)
        self._file_tree.file_clicked.connect(self.file_clicked)
        self._file_tree.highlight_path(Path.ROOT, file_path)


func file_clicked(file_path: Path) -> void:
    if file_path.as_string() == "/directory1/file1":
        self._file_tree.file_clicked.disconnect(self.file_clicked)
        self._file_tree.highlight_path(Path.ROOT, file_path)
        self._next_button.disabled = false


func finish() -> void:
    self._file_tree.highlight_path(Path.ROOT, Path.ROOT)
    self.completed.emit(
        preload("res://visualfs/narrator/lesson/directories/directory_02.gd").new()
    )
    assert(
        self.get_reference_count() == 1,
        "Not all references to file_05 removed before checkpoint exit."
    )
