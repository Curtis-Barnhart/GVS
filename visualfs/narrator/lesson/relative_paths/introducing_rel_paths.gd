extends "res://visualfs/narrator/lesson/checkpoint.gd"

const Path = GVSClassLoader.gvm.filesystem.Path
const UtilString = GVSClassLoader.shared.scripts.Strings
const FileList = GVSClassLoader.visualfs.FileList
const FileTree = GVSClassLoader.visual.FileTree
const TNode = GVSClassLoader.visual.file_nodes.TreeNode

var _file_tree: FileTree
var _active_hl: int = -1
var _path_label: RichTextLabel


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


func remove_old_files() -> void:
    var old_files: Array = self._fs_man.read_files_in_dir(Path.ROOT)
    var old_dirs: Array = self._fs_man.read_dirs_in_dir(Path.ROOT)

    for old_file: Path in old_files:
        self._fs_man.remove_file(old_file)

    for old_dir: Path in old_dirs:
        self._fs_man.remove_recursive(old_dir)


func start(needs_context: bool) -> void:
    if needs_context:
        self.context_build()

    self._inst.remove_all()
    self._inst.render()

    self._text_display.text = UtilString.make_article(
        [
            "Relative Paths",
            [
                "Explain how relative paths work here"
            ]
        ]
    )

    self.remove_old_files()
    self._viewport.move_cam_to(Vector2.ZERO)

    self._path_label = RichTextLabel.new()
    self._right_panel.add_child(self._path_label)
    self._path_label.bbcode_enabled = false
    self._path_label.fit_content = true
    self._path_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
    self._path_label.size_flags_horizontal = Control.SIZE_FILL
    self._path_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    self._path_label.add_theme_stylebox_override("normal", GVSClassLoader.shared.resources.TextBox)
    self._path_label.name = "PathLabel"
    self._write_path_label(".")

    self._fs_man.create_dir(Path.new(["school"]))
    await GVSGlobals.wait(0.5)
    self._viewport.move_cam_to(Vector2(0, TNode.HEIGHT * 0.5))
    await GVSGlobals.wait(1)
    self._fs_man.create_dir(Path.new(["school", "homework"]))
    await GVSGlobals.wait(0.5)
    self._viewport.move_cam_to(Vector2(0, TNode.HEIGHT * 1))
    await GVSGlobals.wait(1)
    self._fs_man.create_file(Path.new(["school", "homework", "math"]))
    self._fs_man.create_file(Path.new(["school", "homework", "english"]))
    self._fs_man.create_file(Path.new(["school", "homework", "chemistry"]))
    await GVSGlobals.wait(0.5)
    self._viewport.move_cam_to(Vector2(0, TNode.HEIGHT * 1.5))
    await GVSGlobals.wait(1)


    self._next_button.pressed.connect(self._set_cwd)
    self._next_button.disabled = false


func _set_cwd() -> void:
    self._file_tree.cwd_text = preload("res://visual/assets/cwd_open.svg")
    self._file_tree.change_cwd(Path.new(["school", "homework"]), Path.ROOT)
    self._next_button.pressed.disconnect(self._set_cwd)
    self._next_button.pressed.connect(self.show_relative_path)


func show_relative_path() -> void:
    self._text_display.text = UtilString.make_article(
        [
            "Relative Paths",
            [
                "clicking on children"
            ]
        ]
    )
    self._next_button.disabled = false
    self._next_button.pressed.disconnect(self.show_relative_path)
    self._next_button.pressed.connect(self.show_relative_path_parents)
    self._file_tree.file_clicked.connect(self._display_children)


func _write_path_label(text: String) -> void:
    self._path_label.text = ""
    # We set these text things here and then never change/pop them
    self._path_label.push_font(GVSClassLoader.shared.fonts.Normal)
    self._path_label.push_font_size(48)
    self._path_label.push_color(Color.WHITE)
    self._path_label.add_text("Relative Path:\n%s" % text)


func _display_children(p: Path) -> void:
    var h_path := Path.new(["school", "homework"])
    if self._active_hl >= 0:
        self._file_tree.hl_server.pop_id(self._active_hl)
        self._active_hl = -1

    if self._fs_man.contains_file(p):
        self._active_hl = self._file_tree.hl_server.push_color_to_tree_nodes(Color.GREEN, h_path, Path.new([p.last()]))
        self._write_path_label(p.last())
    else:
        self._file_tree.hl_server.push_flash_to_tree_nodes(Color.RED, 2.0, h_path, self._fs_man.relative_to(p, h_path))
        if p.as_string() == "/school/homework":
            self._write_path_label(".")
        else:
            self._write_path_label(" ")


func show_relative_path_parents() -> void:
    if self._active_hl >= 0:
        self._file_tree.hl_server.pop_id(self._active_hl)
        self._active_hl = -1

    self._text_display.text = UtilString.make_article(
        [
            "Relative Paths",
            [
                "look you can go backwards"
            ]
        ]
    )
    self._next_button.disabled = false
    self._next_button.pressed.disconnect(self.show_relative_path_parents)
    self._next_button.pressed.connect(self.show_relative_path_all)
    self._file_tree.file_clicked.disconnect(self._display_children)
    self._file_tree.file_clicked.connect(self._display_parents)

    if self._active_hl >= 0:
        self._file_tree.hl_server.pop_id(self._active_hl)
        self._active_hl = -1

    self._write_path_label(" ")


func _display_parents(p: Path) -> void:
    var h_path := Path.new(["school", "homework"])
    if self._active_hl >= 0:
        self._file_tree.hl_server.pop_id(self._active_hl)
        self._active_hl = -1

    if p.common_with(h_path).as_string() != h_path.as_string():
        self._active_hl = self._file_tree.hl_server.push_color_to_tree_nodes(
            Color.GREEN, h_path, self._fs_man.relative_to(p, h_path)
        )
        self._write_path_label(self._fs_man.relative_to(p, h_path).as_string(false))
    else:
        self._file_tree.hl_server.push_flash_to_tree_nodes(Color.RED, 2.0, h_path, self._fs_man.relative_to(p, h_path))
        self._write_path_label(" ")


func show_relative_path_all() -> void:
    if self._active_hl >= 0:
        self._file_tree.hl_server.pop_id(self._active_hl)
        self._active_hl = -1

    self._text_display.text = UtilString.make_article(
        [
            "Relative Paths",
            [
                "look you can even go back down after you go up"
            ]
        ]
    )

    self._next_button.disabled = false
    self._next_button.pressed.disconnect(self.show_relative_path_all)
    self._next_button.pressed.connect(self.finish)

    self._fs_man.create_dir(Path.new(["pictures"]))
    await GVSGlobals.wait(0.5)
    self._fs_man.create_file(Path.new(["pictures", "something"]))
    await GVSGlobals.wait(0.5)

    self._file_tree.file_clicked.disconnect(self._display_parents)
    self._file_tree.file_clicked.connect(self._display_all)

    if self._active_hl >= 0:
        self._file_tree.hl_server.pop_id(self._active_hl)
        self._active_hl = -1

    self._write_path_label(" ")


func _display_all(p: Path) -> void:
    var h_path := Path.new(["school", "homework"])
    if self._active_hl >= 0:
        self._file_tree.hl_server.pop_id(self._active_hl)
        self._active_hl = -1

    if p.as_string() == h_path.as_string():
        self._write_path_label(".")
    else:
        self._active_hl = self._file_tree.hl_server.push_color_to_tree_nodes(
            Color.GREEN, h_path, self._fs_man.relative_to(p, h_path)
        )
        self._write_path_label(self._fs_man.relative_to(p, h_path).as_string(false))


func finish() -> void:
    if self._active_hl >= 0:
        self._file_tree.hl_server.pop_id(self._active_hl)
        self._active_hl = -1
    self._write_path_label(" ")

    self._inst.remove_all()
    self._inst.render()

    self.completed.emit(
        preload("res://visualfs/narrator/lesson/relative_paths/reading_rel_paths.gd").new()
    )
    assert(
        self.get_reference_count() == 1,
        "Not all references to introducing_rel_paths removed before checkpoint exit."
    )
