extends "res://visualfs/narrator/lesson/checkpoint.gd"

const UtilString = GVSClassLoader.shared.Strings
const FileTree = GVSClassLoader.visual.FileTree
const Path = GVSClassLoader.gvm.filesystem.Path

var _file_tree: FileTree
var _targets: Array[Path] = [
    Path.new(["directory0", "subdirectory1"]),
    Path.new(["directory1"]),
    Path.new(["directory0", "subdirectory1", "file1"]),
    Path.new(["directory1", "file1"]),
    Path.new(["file2"])
]
var _target_index: int = 0


func start() -> void:            
    self._file_tree = self._viewport.node_from_scene("FileTree")
    self._line_edit.visible = true
    self._line_edit.text_submitted.connect(self.user_entered)
    self._next_button.pressed.connect(self.finish)
    self._file_tree.highlight_path(Path.ROOT, self._targets[0])
    
    self._text_display.text = UtilString.make_article(
        [
            "User writes out paths",
            [
                "Now, to make sure you really got the hang of this,",
                "let's try some exercises in the reverse direction -",
                "I'll highlight some paths for you,",
                "and you can type out their paths in the text entry box below.",
                "Press the enter key when you have finished typing out a path.",
                "If it is not the correct path, nothing will happen when you",
                "press the enter key, and you will able to modify the path",
                "you are typing and try again.",
                "If it is the correct path, then the text you typed will disappear",
                "and a new path will be highlighted for you to label."
            ],
        ]
    )


func user_entered(text: String) -> void:
    if (
        self._target_index < self._targets.size()
        and text.strip_edges() == self._targets[self._target_index].as_string()
    ):
        self._line_edit.clear()
        self._target_index += 1
        if self._target_index == self._targets.size():
            self._file_tree.highlight_path(Path.ROOT, Path.ROOT)
            self._line_edit.visible = false
            self._next_button.disabled = false
        else:
            self._file_tree.highlight_path(Path.ROOT, self._targets[self._target_index])


func finish() -> void:
    self.completed.emit(
        preload("res://visualfs/narrator/lesson/directories/directory_05.gd").new()
    )
    assert(
        self.get_reference_count() == 1,
        "Not all references to directory_04 removed before checkpoint exit."
    )
