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
    Path.new(["work", "email_2"])
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
                "write /work/email"
            ],
        ]
    )
    
    self._right_panel.add_child(self._line_edit)
    self._line_edit.size_flags_vertical = Control.SIZE_SHRINK_END
    self._line_edit.size_flags_horizontal = Control.SIZE_FILL
    self._line_edit.add_theme_stylebox_override("normal", GVSClassLoader.shared.resources.TextBox)
    self._line_edit.add_theme_font_override("font", GVSClassLoader.shared.fonts.Normal)
    self._line_edit.add_theme_font_size_override("font_size", 48)
    
    self._line_edit.text_changed.connect(self._on_user_path)


func _on_user_path(s: String) -> void:
    var path: Path
    if not s.begins_with("/"):
        path = Path.ROOT
    else:
        path = Path.new(s.split("/", false))
    self._validate_user_path(path)


func _highlight_user_path(p: Path, target_index: int) -> void:
    var target: Path = self._target_paths[target_index]
    var simplified: Path = self._fs_man.reduce_path(p)
    var correct: Path = simplified.common_with(target)
    var simplest_correct: Path = p.all_slices().filter(func (p: Path) -> bool:
        return self._fs_man.reduce_path(p).as_string() == correct.as_string()
    ).next()
    var incorrect: Path = self._fs_man.relative_to(p, simplest_correct)
    
    if self._good_hl >= 0:
        self._file_tree.hl_server.pop_id(self._good_hl)
    if self._bad_hl >= 0:
        self._file_tree.hl_server.pop_id(self._bad_hl)
    
    self._good_hl = self._file_tree.hl_server.push_color_to_tree_nodes(Color.GREEN, Path.ROOT, simplest_correct)
    self._bad_hl = self._file_tree.hl_server.push_color_to_tree_nodes(Color.RED, simplest_correct, incorrect)


func _validate_user_path(p: Path) -> void:
    # TODO: Remember that you can't backtrack from a file!!!
    var target: Path = self._target_paths[self._target_index]
    var simplified: Path = self._fs_man.reduce_path(p)
    var ancestor: Path = self._fs_man.real_ancestry(p)
    var highlight_target: int = self._target_index
        
    if simplified == null:
        print("Path not detected, fallback to ancestor")
        simplified = self._fs_man.reduce_path(ancestor)
        print("Path detected (simplified): ", simplified.as_string())
    else:
        print("Path detected (simplified): ", simplified.as_string())
        if simplified.as_string() == target.as_string():
            print("Path matches expected: ", target.as_string())
            self._next_button.disabled = false
            self._target_index += 1
            print("correct path answer, next question")
            # TODO: somehow we mark if the user finished all in here
        print("Path does not match expected: ", target.as_string())

    self._highlight_user_path(ancestor, highlight_target)


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
