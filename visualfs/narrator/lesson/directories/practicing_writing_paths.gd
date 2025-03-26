extends "res://visualfs/narrator/lesson/checkpoint.gd"

const Path = GVSClassLoader.gvm.filesystem.Path
const UtilString = GVSClassLoader.shared.scripts.Strings
const FileList = GVSClassLoader.visualfs.FileList
const FileTree = GVSClassLoader.visual.FileTree

var _file_tree: FileTree
var _path_label: RichTextLabel
var _highlight_id: int = -1

var _target_paths: Array[Path] = [
    Path.new(["school"]),
    Path.new(["work"])
]
var _target_index: int = 0


func context_build() -> void:
    var ft := FileTree.make_new()
    self._file_tree = FileTree.make_new()
    ft.name = "FileTree"
    self._viewport.add_to_scene(ft)
    
    self._fs_man.created_dir.connect(ft.create_node_dir)
    self._fs_man.created_file.connect(ft.create_node_file)
    self._fs_man.removed_dir.connect(ft.remove_node)
    self._fs_man.removed_file.connect(ft.remove_node)
    
    self._path_label = RichTextLabel.new()
    self._right_panel.add_child(self._path_label)
    self._path_label.bbcode_enabled = false
    self._path_label.fit_content = true
    self._path_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
    self._path_label.size_flags_horizontal = Control.SIZE_FILL
    self._path_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    self._path_label.add_theme_stylebox_override("normal", GVSClassLoader.shared.resources.TextBox)


func start(needs_context: bool) -> void:
    if needs_context:
        self.context_build()
    
    self._file_tree = self._viewport.node_from_scene("FileTree")
    self._path_label = self._right_panel.get_node("PathLabel")
    
    self._text_display.text = UtilString.make_article(
        [
            "Practice reading paths!",
            [
                "click on... /directory"
            ],
        ]
    )
    
    self._label_write("/")
    
    self._file_tree.file_clicked.connect(self.user_click_object)


func user_click_object(p: Path) -> void:    
    # Remove old highlight/record if applicable
    if self._highlight_id >= 0:
        self._file_tree.hl_server.pop_id(self._highlight_id)
        self._highlight_id = -1
    
    # Calculate good and bad parts of next highlight
    var target: Path = self._target_paths[self._target_index]
    if p.as_string() == target.as_string():
        self._next_button.disabled = false
        self._highlight_id = self._file_tree.hl_server.push_color_to_tree_nodes(
            Color.GREEN, Path.ROOT, p
        )
        self._label_write(p.as_string(), Color.GREEN)
        self._target_index += 1
    else:
        var correct: Path = p.common_with(target)
        var remaining: Path = self._fs_man.relative_to(p, correct)
        # TODO: I don't know if making the green hold longer is a silly choice
        self._file_tree.hl_server.push_flash_to_tree_nodes(
            Color.GREEN, 3, Path.ROOT, correct
        )
        self._label_write(correct.as_string(), Color.GREEN)
        self._file_tree.hl_server.push_flash_to_tree_nodes(
            Color.RED, 1, correct, remaining
        )
        self._label_append(remaining.as_string(correct.as_string() != "/"), Color.RED)

    # Enable moving to next section after all targets completed
    if self._target_index == self._target_paths.size():
        self._file_tree.file_clicked.disconnect(self.user_click_object)
        self._next_button.pressed.connect(self.finish)


## Erases all previous text in the path label and then
## writes colored text to the path label.[br][br]
##
## [param text]: Text to write to the label.[br]
## [param color]: Color to write [code]text[/code] in.
func _label_write(text: String, color: Color = Color.WHITE) -> void:
    self._path_label.text = ""  # also clears tag stack
    self._path_label.push_font(GVSClassLoader.shared.fonts.Normal)
    self._path_label.push_font_size(48)
    self._path_label.push_color(Color.WHITE)
    self._path_label.add_text("Path\n")
    self._path_label.pop()
    self._label_append(text, color)


## Appends colored text to the path label.[br][br]
##
## [param text]: Text to write to the label.[br]
## [param color]: Color to write [code]text[/code] in.
func _label_append(text: String, color: Color = Color.WHITE) -> void:
    self._path_label.push_color(color)
    self._path_label.add_text(text)
    self._path_label.pop()


func finish() -> void:
    if self._highlight_id >= 0:
        self._file_tree.hl_server.pop_id(self._highlight_id)
    self.completed.emit(
        preload("res://visualfs/narrator/lesson/completion.gd").new()
    )
    assert(
        self.get_reference_count() == 1,
        "Not all references to practicing_writing_paths removed before checkpoint exit."
    )
