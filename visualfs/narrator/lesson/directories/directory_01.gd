extends "res://visualfs/narrator/lesson/checkpoint.gd"

const UtilString = GVSClassLoader.shared.Strings
const FileList = GVSClassLoader.visualfs.FileList
const FileTree = GVSClassLoader.visual.FileTree
const Path = GVSClassLoader.gvm.filesystem.Path
const File = GVSClassLoader.visual.file_nodes.BaseNode
const Menu = GVSClassLoader.visual.buttons.CircleMenu
const GPopup = GVSClassLoader.visual.GVSPopup
const FileReader = GVSClassLoader.visual.FileReader
const FileWriter = GVSClassLoader.visual.FileWriter
const FCreateInput = GVSClassLoader.visual.SimpleInput

var _file_tree: FileTree


func start() -> void:            
    # Create file tree object in drag viewport connected to the fs_manager
    self._file_tree = self._viewport.node_from_scene("FileTree")
    self._file_tree.file_clicked.connect(self.directory_clicked)
    self._next_button.pressed.connect(self.finish)
    self._next_button.disabled = true
    
    self._text_display.text = UtilString.make_article(
        [
            "Finding Files... the Smart Way",
            [
                "Let's consider a more complicated example,",
                "one with another road in between you and your goal."
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
        preload("res://visualfs/narrator/lesson/directories/directory_02.gd").new(
            self._fs_man, self._next_button, self._text_display, self._viewport
        )
    )
    assert(
        self.get_reference_count() == 1,
        "Not all references to file_05 removed before checkpoint exit."
    )
