extends "res://visualfs/narrator/lesson/checkpoint.gd"

const Path = GVSClassLoader.gvm.filesystem.Path
const UtilString = GVSClassLoader.shared.scripts.Strings
const FileList = GVSClassLoader.visualfs.FileList
const FileTree = GVSClassLoader.visual.FileTree
const TNode = GVSClassLoader.visual.file_nodes.TreeNode

var _file_tree: FileTree
var _target_hl: int = -1
var _good_hl: int = -1
var _bad_hl: int = -1
var _line_edit := LineEdit.new()

var _target_paths: Array[Path] = [
    Path.new(["school"]),
    Path.new(["work"])
]
var _target_index: int = 0


func context_build() -> void:
    var file_tree := FileTree.make_new()
    file_tree = FileTree.make_new()
    file_tree.name = "FileTree"
    self._viewport.add_to_scene(file_tree)
    
    self._fs_man.created_dir.connect(file_tree.create_node_dir)
    self._fs_man.created_file.connect(file_tree.create_node_file)
    self._fs_man.removed_dir.connect(file_tree.remove_node)
    self._fs_man.removed_file.connect(file_tree.remove_node)
    
    self._fs_man.create_dir(Path.new(["school"]))
    self._fs_man.create_dir(Path.new(["work"]))
    self._fs_man.create_file(Path.new(["school", "document"]))
    self._fs_man.create_file(Path.new(["school", "email"]))
    self._fs_man.create_file(Path.new(["work", "email"]))
    self._fs_man.create_file(Path.new(["work", "email_2"]))
    self._viewport.move_cam_to(Vector2(0, TNode.HEIGHT))
    
    var path_label := RichTextLabel.new()
    self._right_panel.add_child(path_label)
    path_label.name = "PathLabel"


func start(needs_context: bool) -> void:
    if needs_context:
        self.context_build()
    
    self._file_tree = self._viewport.node_from_scene("FileTree")
    self._right_panel.get_node("PathLabel").queue_free()
    
    self._text_display.text = UtilString.make_article(
        [
            "Practice writing paths!",
            [
                "write something"
            ],
        ]
    )
    
    self._right_panel.add_child(self._line_edit)
    self._line_edit.size_flags_vertical = Control.SIZE_SHRINK_END
    self._line_edit.size_flags_horizontal = Control.SIZE_FILL
    self._line_edit.add_theme_stylebox_override("normal", GVSClassLoader.shared.resources.TextBox)
    self._line_edit.add_theme_font_override("font", GVSClassLoader.shared.fonts.Normal)
    self._line_edit.add_theme_font_size_override("font_size", 48)


func _get_user_path(s: String) -> Path:
    return null


func _highlight_user_path(p: Path) -> void:
    pass


func finish() -> void:
    if self._target_hl >= 0:
        self._file_tree.hl_server.pop_id(self._target_hl)
    if self._good_hl >= 0:
        self._file_tree.hl_server.pop_id(self._good_hl)
    if self._bad_hl >= 0:
        self._file_tree.hl_server.pop_id(self._bad_hl)
    
    self.completed.emit(
        preload("res://visualfs/narrator/lesson/completion.gd").new()
    )
    assert(
        self.get_reference_count() == 1,
        "Not all references to practicing_writing_paths removed before checkpoint exit."
    )
