extends "res://visualfs/narrator/lesson/checkpoint.gd"

const UtilString = GVSClassLoader.shared.Strings
const FileTree = GVSClassLoader.visual.FileTree
const Path = GVSClassLoader.gvm.filesystem.Path

var _file_tree: FileTree


func start() -> void:            
    self._file_tree = self._viewport.node_from_scene("FileTree")
    self._file_tree.file_clicked.connect(self.node_clicked)
    self._next_button.pressed.connect(self.finish)
    
    self._text_display.text = UtilString.make_article(
        [
            "Relative Paths",
            [
                ""
            ],
        ]
    )


func node_clicked(file_path: Path) -> void:
    self._file_tree.highlight_path(Path.ROOT, file_path)
    if file_path.as_string() == "/file0":
        self._next_button.disabled = false


func finish() -> void:
    self._file_tree.highlight_path(Path.ROOT, Path.ROOT)
    self.completed.emit(
        preload("res://visualfs/narrator/lesson/completion.gd").new(
            self._fs_man, self._next_button, self._text_display, self._viewport
        )
    )
    assert(
        self.get_reference_count() == 1,
        "Not all references to directory_04 removed before checkpoint exit."
    )
