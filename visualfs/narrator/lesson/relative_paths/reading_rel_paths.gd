extends "res://visualfs/narrator/lesson/checkpoint.gd"

const Path = GVSClassLoader.gvm.filesystem.Path
const UtilString = GVSClassLoader.shared.scripts.Strings
const FileList = GVSClassLoader.visualfs.FileList
const FileTree = GVSClassLoader.visual.FileTree
const TNode = GVSClassLoader.visual.file_nodes.TreeNode

var _file_tree: FileTree
var _active_hl: int = -1
var _path_label: RichTextLabel

var _target_paths: Array = [
    [Path.new(["projects", "school"]), Path.new(["..", "game"])],
    [Path.new(["projects", "school"]), Path.new(["homework_0"])],
    [Path.new(["projects", "school"]), Path.new(["..", "..", "pictures", "vacation"])],
    [Path.new(["pictures", "nature"]), Path.new(["..", ".."])],
    [Path.new(["pictures", "nature"]), Path.new(["..", "vacation", "flowers"])],
    [Path.new(["pictures", "nature"]), Path.new(["..", "..", "document_1"])],
    [Path.new(["pictures"]), Path.new(["."])],
    [Path.new(["pictures"]), Path.new([".", ".", "."])],
    [Path.new(["pictures"]), Path.new(["..", "pictures", "..", "document_1"])],
]
var _target_index: int = 0


func context_build() -> void:
    self._file_tree = FileTree.make_new()
    self._file_tree.cwd_text = preload("res://visual/assets/directory_open.svg")
    self._file_tree.name = "FileTree"
    self._viewport.add_to_scene(self._file_tree)
    self._fs_man.created_dir.connect(self._file_tree.create_node_dir)
    self._fs_man.created_file.connect(self._file_tree.create_node_file)
    self._fs_man.removed_dir.connect(self._file_tree.remove_node)
    self._fs_man.removed_file.connect(self._file_tree.remove_node)

    var fl := FileList.make_new()
    fl.name = "FileList"
    self._viewport.add_to_scene(fl)
    self._inst.visible = false

    self._path_label = RichTextLabel.new()
    self._right_panel.add_child(self._path_label)
    self._path_label.bbcode_enabled = false
    self._path_label.fit_content = true
    self._path_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
    self._path_label.size_flags_horizontal = Control.SIZE_FILL
    self._path_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    self._path_label.add_theme_stylebox_override("normal", GVSClassLoader.shared.resources.TextBox)
    self._path_label.name = "PathLabel"
    self._label_write(" ")

    self._file_tree.cwd_text = preload("res://visual/assets/cwd_open.svg")


func remove_old_files() -> void:
    var old_files: Array = self._fs_man.read_files_in_dir(Path.ROOT)
    var old_dirs: Array = self._fs_man.read_dirs_in_dir(Path.ROOT)

    for old_file: Path in old_files:
        self._fs_man.remove_file(old_file)

    for old_dir: Path in old_dirs:
        self._fs_man.remove_recursive(old_dir)


func make_tree() -> void:
    self._fs_man.create_dir(Path.new(["projects"]))
    self._fs_man.create_file(Path.new(["document_0"]))
    self._fs_man.create_file(Path.new(["document_1"]))
    self._fs_man.create_dir(Path.new(["pictures"]))
    await GVSGlobals.wait(2)
    self._viewport.move_cam_to(Vector2(0, TNode.HEIGHT * 0.5))

    self._fs_man.create_file(Path.new(["projects", "game"]))
    self._fs_man.create_file(Path.new(["projects", "movie"]))
    self._fs_man.create_dir(Path.new(["projects", "school"]))
    self._fs_man.create_dir(Path.new(["pictures", "vacation"]))
    self._fs_man.create_dir(Path.new(["pictures", "nature"]))
    await GVSGlobals.wait(2)
    self._viewport.move_cam_to(Vector2(0, TNode.HEIGHT))

    self._fs_man.create_file(Path.new(["projects", "school", "homework_0"]))
    self._fs_man.create_file(Path.new(["projects", "school", "homework_1"]))
    self._fs_man.create_file(Path.new(["pictures", "vacation", "flowers"]))
    self._fs_man.create_file(Path.new(["pictures", "vacation", "hike_0"]))
    self._fs_man.create_file(Path.new(["pictures", "vacation", "hike_1"]))
    self._fs_man.create_dir(Path.new(["pictures", "nature", "butterflies"]))
    self._viewport.move_cam_to(Vector2(0, TNode.HEIGHT * 1.5))


func start(needs_context: bool) -> void:
    if needs_context:
        self.context_build()

    self._file_tree = self._viewport.node_from_scene("FileTree")
    assert(self._file_tree != null)
    self._path_label = self._right_panel.get_node("PathLabel")
    assert(self._path_label != null)

    self._text_display.text = UtilString.make_article(
        [
            "Reading Relative Paths",
            [
                "now you click on the relative path (projects/school to ../game)"
            ]
        ]
    )

    self.remove_old_files()
    self._viewport.move_cam_to(Vector2.ZERO)
    await GVSGlobals.wait(0.5)

    await self.make_tree()
    await GVSGlobals.wait(2)

    self._file_tree.change_cwd(
        self._target_paths[self._target_index][0] as Path, Path.ROOT
    )
    self._viewport.move_cam_to(self._file_tree.node_rel_pos_from_path(
        self._target_paths[self._target_index][0] as Path
    ))
    await GVSGlobals.wait(2)

    self._inst.visible = true
    self._inst.add_command(Instructions.Command.new(
        "click on %s relative to %s" % [
            (self._target_paths[self._target_index][1] as Path).as_string(false),
            (self._target_paths[self._target_index][0] as Path).as_string()
        ]
    ))
    self._inst.render()

    self._next_button.disabled = false
    self._file_tree.file_clicked.connect(self.user_click_object)


func user_click_object(p: Path) -> void:
    # Remove old highlight/record if applicable
    if self._active_hl >= 0:
        self._file_tree.hl_server.pop_id(self._active_hl)
        self._active_hl = -1

    # Calculate good and bad parts of next highlight
    var origin: Path = self._target_paths[self._target_index][0]
    var target: Path = self._target_paths[self._target_index][1]
    var p_relative: Path = self._fs_man.relative_to(p, origin)

    if p_relative.as_string() == self._fs_man.relative_to(self._fs_man.reduce_path(origin.compose(target)), origin).as_string():
        self.user_click_object_correct(p)
    else:
        var correct: Path = p_relative.common_with(target)
        var remaining: Path = self._fs_man.relative_to(p, origin.compose(correct))
        # TODO: I don't know if making the green hold longer is a silly choice
        self._file_tree.hl_server.push_flash_to_tree_nodes(
            Color.GREEN, 3, origin, correct
        )
        self._label_write(correct.as_string(false), Color.GREEN)
        self._file_tree.hl_server.push_flash_to_tree_nodes(
            Color.RED, 1, self._fs_man.reduce_path(origin.compose(correct)), remaining
        )
        if not remaining.degen():
            self._label_append(remaining.as_string(not correct.degen()), Color.RED)
        elif correct.degen():
            self._label_append(" ")


func user_click_object_correct(p: Path) -> void:
    self._next_button.disabled = false
    var old_origin: Path = self._target_paths[self._target_index][0]
    var p_relative: Path = self._fs_man.relative_to(p, old_origin)
    self._label_write(p_relative.as_string(false), Color.GREEN)
    self._target_index += 1
    self._active_hl = self._file_tree.hl_server.push_color_to_tree_nodes(
        Color.GREEN, old_origin, p_relative
    )

    # Enable moving to next section after all targets completed or
    # set next target if not all done
    self._inst.get_command(-1).set_fulfill(true)
    if self._target_index == self._target_paths.size():
        self._file_tree.file_clicked.disconnect(self.user_click_object)
        self._next_button.pressed.connect(self.finish)
        self._inst.render()
    else:
        var new_origin: Path = self._target_paths[self._target_index][0]
        self._inst.add_command(Instructions.Command.new(
            "click on %s relative to %s" % [
                (self._target_paths[self._target_index][1] as Path).as_string(false),
                new_origin.as_string()
            ]
        ))
        self._inst.render()

        if new_origin.as_string() != old_origin.as_string():
            await GVSGlobals.wait(1)
            self._file_tree.change_cwd(new_origin, old_origin)
            self._viewport.move_cam_to(
                self._file_tree.node_rel_pos_from_path(new_origin)
            )
            await GVSGlobals.wait(2)


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
    if self._active_hl >= 0:
        self._file_tree.hl_server.pop_id(self._active_hl)
        self._active_hl = -1

    self._inst.remove_all()
    self._inst.render()

    self.completed.emit(
        preload("res://visualfs/narrator/lesson/completion.gd").new()
    )
    assert(
        self.get_reference_count() == 1,
        "Not all references to reading_rel_paths removed before checkpoint exit."
    )
