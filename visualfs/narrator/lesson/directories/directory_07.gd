extends "res://visualfs/narrator/lesson/checkpoint.gd"

const FManager = GVSClassLoader.gvm.filesystem.Manager
const Path = GVSClassLoader.gvm.filesystem.Path
const FileTree = GVSClassLoader.visual.FileTree
const File = GVSClassLoader.visual.file_nodes.BaseNode
const Dir = GVSClassLoader.visual.file_nodes.TreeNode
const Menu = GVSClassLoader.visual.buttons.CircleMenu
const TreeNode = GVSClassLoader.visual.file_nodes.TreeNode
const GPopup = GVSClassLoader.visual.GVSPopup
const FileReader = GVSClassLoader.visual.FileReader
const FileWriter = GVSClassLoader.visual.FileWriter
const FCreateInput = GVSClassLoader.visual.SimpleInput
const UtilString = GVSClassLoader.shared.Strings

var _file_tree: FileTree


func start(needs_context: bool) -> void:            
    self._file_tree = self._viewport.node_from_scene("FileTree")
    #self._file_tree.file_clicked.connect(self.menu_popup)
    self._next_button.pressed.connect(self.finish)
    
    self._text_display.text = UtilString.make_article(
        [
            "User finding files again",
            [
                "To complete this section",
            ],
        ]
    )


func finish() -> void:
    self._file_tree.highlight_path(Path.ROOT, Path.ROOT)
    self.completed.emit(
        preload("res://visualfs/narrator/lesson/directories/directory_08.gd").new()
    )
    assert(
        self.get_reference_count() == 1,
        "Not all references to directory_08 removed before checkpoint exit."
    )
