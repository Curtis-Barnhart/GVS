extends "res://visualfs/narrator/lesson/checkpoint.gd"

const Path = GVSClassLoader.gvm.filesystem.Path
const UtilString = GVSClassLoader.shared.scripts.Strings
const FileList = GVSClassLoader.visualfs.FileList
const FileTree = GVSClassLoader.visual.FileTree

var _file_tree: FileTree
var _path_label := RichTextLabel.new()
var _highlight_id: int = -1


func context_build() -> void:
    self._file_tree = FileTree.make_new()
    self._file_tree.name = "FileTree"
    self._viewport.add_to_scene(self._file_tree)
    
    self._fs_man.created_dir.connect(self._file_tree.create_node_dir)
    self._fs_man.created_file.connect(self._file_tree.create_node_file)
    self._fs_man.removed_dir.connect(self._file_tree.remove_node)
    self._fs_man.removed_file.connect(self._file_tree.remove_node)
    
    self._fs_man.create_dir(Path.new(["school"]))
    self._fs_man.create_dir(Path.new(["work"]))
    self._fs_man.create_file(Path.new(["school", "document"]))
    self._fs_man.create_file(Path.new(["school", "email"]))
    self._fs_man.create_file(Path.new(["work", "email"]))
    self._fs_man.create_file(Path.new(["work", "email_2"]))


func start(needs_context: bool) -> void:
    if needs_context:
        self.context_build()
    
    self._text_display.text = UtilString.make_article(
        [
            "Exploring paths!",
            [
                "look at all the new files! aoriestn aoiresnt oiaesrnt oiaersnt oiaesrntnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn"
            ],
        ]
    )
    
    self._right_panel.add_child(self._path_label)
    self._path_label.bbcode_enabled = false
    self._path_label.fit_content = true
    self._path_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
    self._path_label.size_flags_horizontal = Control.SIZE_FILL
    self._path_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    self._label_write("/")
    self._path_label.add_theme_stylebox_override("normal", GVSClassLoader.shared.resources.TextBox)

    self._file_tree.file_clicked.connect(self.user_click_object)


func user_click_object(p: Path) -> void:
    self._label_write(p.as_string())
    
    if self._highlight_id >= 0:
        self._file_tree.hl_server.pop_id(self._highlight_id)
    self._highlight_id = self._file_tree.hl_server.push_color_to_tree_nodes(
        Color.DARK_BLUE, Path.ROOT, p
    )


## Erases all previous text in the path label and then
## writes colored text to the path label.[br][br]
##
## [param text]: Text to write to the label.[br]
## [param color]: Color to write [code]text[/code] in. 0 for dark blue,
##      1 for red, and 2 for green.
func _label_write(text: String, color: int = 0) -> void:
    assert(color >= 0 and color <= 2)
    var colors: Array[Color] = [
        Color.DARK_BLUE,
        Color.RED,
        Color.GREEN
    ]
    
    self._path_label.text = ""  # also clears tag stack
    self._path_label.push_font(GVSClassLoader.shared.fonts.Normal)
    self._path_label.push_font_size(48)
    self._path_label.push_color(colors[color])
    self._path_label.add_text(text)
    self._path_label.pop()


## Appends colored text to the path label.[br][br]
##
## [param text]: Text to write to the label.[br]
## [param color]: Color to write [code]text[/code] in. 0 for dark blue,
##      1 for red, and 2 for green.
func _label_append(text: String, color: int = 0) -> void:
    assert(color >= 0 and color <= 2)
    var colors: Array[Color] = [
        Color.DARK_BLUE,
        Color.RED,
        Color.GREEN
    ]
    
    self._path_label.push_color(colors[color])
    self._path_label.add_text(text)
    self._path_label.pop()


func finish() -> void:
    self._file_tree.highlight_path(Path.ROOT, Path.ROOT)
    #self.completed.emit(
        #preload("res://visualfs/narrator/lesson/directories/directory_01.gd").new()
    #)
    assert(
        self.get_reference_count() == 1,
        "Not all references to exploring_paths removed before checkpoint exit."
    )
