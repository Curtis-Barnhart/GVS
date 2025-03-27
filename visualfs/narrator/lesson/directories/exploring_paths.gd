extends "res://visualfs/narrator/lesson/checkpoint.gd"

const Path = GVSClassLoader.gvm.filesystem.Path
const UtilString = GVSClassLoader.shared.scripts.Strings
const FileList = GVSClassLoader.visualfs.FileList
const FileTree = GVSClassLoader.visual.FileTree
const TNode = GVSClassLoader.visual.file_nodes.TreeNode

var _file_tree: FileTree
var _path_label: RichTextLabel
var _highlight_id: int = -1
var _paths_clicked: int = 0


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
    
    self._inst.remove_all()
    self._inst.render()


func start(needs_context: bool) -> void:
    if needs_context:
        self.context_build()
    
    self._file_tree = self._viewport.node_from_scene("FileTree")
    
    self._text_display.text = UtilString.make_article(
        [
            "Exploring paths!",
            [
                "look at all the new files!"
            ],
        ]
    )
    
    self._path_label = RichTextLabel.new()
    self._right_panel.add_child(self._path_label)
    self._path_label.bbcode_enabled = false
    self._path_label.fit_content = true
    self._path_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
    self._path_label.size_flags_horizontal = Control.SIZE_FILL
    self._path_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    self._label_write("/")
    self._path_label.add_theme_stylebox_override("normal", GVSClassLoader.shared.resources.TextBox)
    self._path_label.name = "PathLabel"
    
    self._inst.add_command(Instructions.Command.new(
        "Click on objects to view their paths (0/3)"
    ))
    self._inst.render()

    self._file_tree.file_clicked.connect(self.user_click_object)
    
    self._next_button.pressed.connect(self.finish)


func user_click_object(p: Path) -> void:
    self._paths_clicked += 1
    
    if self._paths_clicked <= 3:
        if self._paths_clicked == 3:
            self._next_button.disabled = false
            self._inst.get_command(0).set_fulfill(true)
    
        self._inst.get_command(0).change_text(
            "Click on objects to view their paths (%d/3)" % min(3, self._paths_clicked)
        )
        self._inst.render()
    
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
## [param color]: Color to write [code]text[/code] in.
func _label_write(text: String, color: Color = Color.WHITE) -> void:
    self._path_label.text = ""  # also clears tag stack
    self._path_label.push_font(GVSClassLoader.shared.fonts.Normal)
    self._path_label.push_font_size(48)
    self._path_label.push_color(Color.WHITE)
    self._path_label.add_text("Path\n")
    self._path_label.pop()
    self._path_label.push_color(color)
    self._path_label.add_text(text)
    self._path_label.pop()


func finish() -> void:
    if self._highlight_id >= 0:
        self._file_tree.hl_server.pop_id(self._highlight_id)
        
    self._inst.remove_all()
    self._inst.render()

    self.completed.emit(
        preload("res://visualfs/narrator/lesson/directories/practicing_reading_paths.gd").new()
    )
    assert(
        self.get_reference_count() == 1,
        "Not all references to exploring_paths removed before checkpoint exit."
    )
