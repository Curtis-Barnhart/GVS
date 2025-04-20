extends "res://visualfs/narrator/lesson/checkpoint.gd"

const Path = GVSClassLoader.gvm.filesystem.Path
const UtilString = GVSClassLoader.shared.scripts.Strings
const FileList = GVSClassLoader.visualfs.FileList
const FileTree = GVSClassLoader.visual.FileTree
const TNode = GVSClassLoader.visual.file_nodes.TreeNode
const Com = Instructions.Command

var _file_tree: FileTree
var _target_hl: int = -1
var _good_hl: int = -1
var _bad_hl: int = -1
var _line_edit := LineEdit.new()

var _target_paths: Array = [
    [Path.new(["projects", "school"]), Path.new(["..", "game"])],
    [Path.new(["projects", "school"]), Path.new(["homework_0"])],
    [Path.new(["pictures", "nature"]), Path.new(["..", ".."])],
    [Path.new(["pictures", "nature"]), Path.new(["..", "vacation", "flowers"])],
    [Path.new(["pictures"]), Path.new(["."])],
    [Path.new(["pictures"]), Path.new([".", ".", "."])],
    [Path.new(["pictures"]), Path.new(["..", "pictures", "..", "document_1"])],
]
var _target_index: int = 0


func context_build() -> void:
    var file_tree := FileTree.make_new()
    file_tree = FileTree.make_new()
    file_tree.name = "FileTree"
    file_tree.cwd_text = preload("res://visual/assets/directory_open.svg")
    self._viewport.add_to_scene(file_tree)

    self._fs_man.created_dir.connect(file_tree.create_node_dir)
    self._fs_man.created_file.connect(file_tree.create_node_file)
    self._fs_man.removed_dir.connect(file_tree.remove_node)
    self._fs_man.removed_file.connect(file_tree.remove_node)

    self._fs_man.create_dir(Path.new(["projects"]))
    self._fs_man.create_file(Path.new(["document_0"]))
    self._fs_man.create_file(Path.new(["document_1"]))
    self._fs_man.create_dir(Path.new(["pictures"]))

    self._fs_man.create_file(Path.new(["projects", "game"]))
    self._fs_man.create_file(Path.new(["projects", "movie"]))
    self._fs_man.create_dir(Path.new(["projects", "school"]))
    self._fs_man.create_dir(Path.new(["pictures", "vacation"]))
    self._fs_man.create_dir(Path.new(["pictures", "nature"]))

    self._fs_man.create_file(Path.new(["projects", "school", "homework_0"]))
    self._fs_man.create_file(Path.new(["projects", "school", "homework_1"]))
    self._fs_man.create_file(Path.new(["pictures", "vacation", "flowers"]))
    self._fs_man.create_file(Path.new(["pictures", "vacation", "hike_0"]))
    self._fs_man.create_file(Path.new(["pictures", "vacation", "hike_1"]))
    self._fs_man.create_dir(Path.new(["pictures", "nature", "butterflies"]))
    self._viewport.move_cam_to(Vector2(0, TNode.HEIGHT * 1.5))
    await GVSGlobals.wait(2)


func start(needs_context: bool) -> void:
    if needs_context:
        await self.context_build()

    self._file_tree = self._viewport.node_from_scene("FileTree")

    self._text_display.text = UtilString.make_article(
        [
            "Practice writing relative paths!",
            [
                "Now it's time for you to practice the reverse -",
                "writing out a relative path to a file given its location.",
            ],
        ]
    )

    self._right_panel.add_child(self._line_edit)
    self._line_edit.size_flags_vertical = Control.SIZE_SHRINK_END
    self._line_edit.size_flags_horizontal = Control.SIZE_FILL
    self._line_edit.add_theme_stylebox_override("normal", GVSClassLoader.shared.resources.TextBox)
    self._line_edit.add_theme_font_override("font", GVSClassLoader.shared.fonts.Normal)
    self._line_edit.add_theme_font_size_override("font_size", 48)
    self._line_edit.set_placeholder("Type path here")
    self._line_edit.text_changed.connect(self._on_user_path)

    self._inst.add_command(Instructions.Command.new(
        "Write the highlighted relative path beginning from the current working directory %s (%d/%d)" % [
            (self._target_paths[self._target_index][0] as Path).as_string(),
            self._target_index + 1,
            self._target_paths.size()
        ]
    ))
    self._inst.render()

    var first_cwd: Path = self._target_paths[self._target_index][0]
    self._file_tree.cwd_text = preload("res://visual/assets/cwd_open.svg")
    await GVSGlobals.wait(1)
    self._file_tree.change_cwd(first_cwd, Path.ROOT)
    self._viewport.move_cam_to(
        self._file_tree.node_rel_pos_from_path(first_cwd)
    )
    self._target_hl = self._file_tree.hl_server.push_color_to_tree_nodes(
        Color.DARK_BLUE,
        first_cwd,
        self._target_paths[self._target_index][1] as Path
    )
    await GVSGlobals.wait(2)


    self._next_button.pressed.connect(self.finish)


func _on_user_path(s: String) -> void:
    var path: Path
    if s.begins_with("/"):
        path = null
    else:
        path = Path.new(s.split("/", false))

    self._suberrors_analyze(s.split("/"))
    self._validate_user_path(path)


var _errs: Dictionary[String, Instructions.Command] = {
    "begins_with_slash": null,
    "bad_dir_contains": null,
    "file_contains": null,
    "wrong_way": null,
}
func _suberrors_analyze(path: PackedStringArray) -> void:
    var target_o: Path = self._target_paths[self._target_index][0]
    var target_p: Path = self._target_paths[self._target_index][1]

    ######################################
    # Check if the user led with a slash #
    ######################################
    if (path.size() > 1) and path[0] == "":
        if self._errs["begins_with_slash"] == null:
            self._errs["begins_with_slash"] = Com.new("Your path begins with '/'")
            self._suberrors_remove_all()
            self._inst.get_command(-1).add_command(self._errs["begins_with_slash"])
            self._inst.render()
            return
    elif self._errs["begins_with_slash"] != null:
        self._inst.remove_command_ref(self._errs["begins_with_slash"])
        self._errs["begins_with_slash"] = null

    var subpath: Path = self._target_paths[self._target_index][0]
    var one_bad_name: bool = false
    # variables for testing if the user is on track
    var sane_path: Path = subpath
    for i: int in GStreams.IRange(0, path.size(), 1):
        ##############################################
        # Check if the user treats a file like a dir #
        ##############################################
        if self._fs_man.contains_file(subpath):
            var err_str: String = "'%s' is a file, and cannot contain other paths, but your path continues with '%s'" % [
                subpath.slice(target_o.size()).as_string(), path.get(i)
            ]
            if self._errs["file_contains"] == null:
                self._errs["file_contains"] = Com.new(err_str)
                self._inst.get_command(-1).add_command(self._errs["file_contains"])
            else:
                self._errs["file_contains"].change_text(err_str)
            sane_path = subpath
            break
        elif self._errs["file_contains"] != null:
            self._inst.remove_command_ref(self._errs["file_contains"])
            self._errs["file_contains"] = null

        if path.get(i) == "":
            continue

        subpath = subpath.extend(path.get(i))
        ########################################################
        # See if the user has typed a path that does not exist #
        ########################################################
        if not self._fs_man.contains_path(subpath):
            if one_bad_name:
                # one iteration ago the user typed a bad name and now they treat it as a directory
                var err_str: String = "Your path is valid through '%s', but this path does not contain any subdirectory '%s'" % [
                    subpath.slice(target_o.size(), -2).as_string(), path.get(i - 1)
                ]
                if self._errs["file_contains"] == null:
                    self._errs["file_contains"] = Com.new(err_str)
                else:
                    self._errs["file_contains"].change_text(err_str)
                sane_path = subpath.slice(0, -2)
                break
            else:
                # the user has typed a bad name of some sort (they might not be finished)
                sane_path = subpath.base()
                one_bad_name = true
        else:
            sane_path = subpath

    ########################################
    # See if the user has gotten off track #
    ########################################
    var splits: Array[Path] = []
    splits.assign(self._fs_man.path_branches_abs(
        target_o.compose(target_p), sane_path, target_o.size()
    ))
    if splits[2].degen():
        if self._errs["wrong_way"] != null:
            self._inst.remove_command_ref(self._errs["wrong_way"])
            self._errs["wrong_way"] = null
    else:
        var com_str: String = "good up to '%s', but goes off the rails at '%s'" % [
            splits[0].slice(target_o.size()).as_string(false),
            splits[2].slice(0, 1).as_string(false)
        ]
        if self._errs["wrong_way"] == null:
            self._errs["wrong_way"] = Com.new(com_str)
            self._inst.get_command(-1).add_command(self._errs["wrong_way"])
        else:
            self._errs["wrong_way"].change_text(com_str)

    self._inst.render()


## Removes all suberrors from the most recent instruction
func _suberrors_remove_all() -> void:
    for err: String in self._errs.keys():
        self._inst.remove_command_ref(self._errs[err])
    self._inst.render()


## [param p]: null iff user started path with /
func _validate_user_path(p: Path) -> void:
    # the _target_index member changes if _user_answered_correctly triggered
    var highlight_target: int = self._target_index
    var p_abs_ancestor: Path

    if self._good_hl >= 0:
        self._file_tree.hl_server.pop_id(self._good_hl)
    if self._bad_hl >= 0:
        self._file_tree.hl_server.pop_id(self._bad_hl)

    if p != null:
        var t_origin: Path = self._target_paths[self._target_index][0]
        var t_path: Path = self._target_paths[self._target_index][1]
        var p_abs: Path = t_origin.compose(p)
        var p_abs_simplified: Path = self._fs_man.reduce_path(p_abs)
        p_abs_ancestor = self._fs_man.real_ancestry(p_abs)

        if p_abs_simplified == null:
            p_abs_simplified = self._fs_man.reduce_path(p_abs_ancestor)
        else:
            if p_abs_simplified.as_string() == self._fs_man.reduce_path(t_origin.compose(t_path)).as_string():
                self._suberrors_remove_all()
                self._user_answered_correctly()

        self._highlight_user_path(p_abs_ancestor, highlight_target)


## [param p]: absolute path made of the target origin plus the user's input.[br]
## [param target_index]: target_index to use to figure out current target
func _highlight_user_path(p: Path, target_index: int) -> void:
    var origin: Path = self._target_paths[target_index][0]
    var target: Path = self._target_paths[target_index][1]

    var branching: Array[Path] = []
    branching.assign(self._fs_man.path_branches_abs(
        origin.compose(target), p, origin.size()
    ))

    var correct: Path = branching[0].slice(origin.size())
    var incorrect: Path = branching[2]

    self._good_hl = self._file_tree.hl_server.push_color_to_tree_nodes(Color.GREEN, origin, correct)
    self._bad_hl = self._file_tree.hl_server.push_color_to_tree_nodes(Color.RED, origin.compose(correct), incorrect)


func _user_answered_correctly() -> void:
    var old_origin: Path = self._target_paths[self._target_index][0]
    self._target_index += 1
    self._inst.get_command(-1).set_fulfill(true)
    self._file_tree.hl_server.pop_id(self._target_hl)
    self._target_hl = -1

    if self._target_index == self._target_paths.size():
        self._next_button.disabled = false
        self._line_edit.text_changed.disconnect(self._on_user_path)
        self._inst.render()
    else:
        var new_origin: Path = self._target_paths[self._target_index][0]
        self._inst.add_command(Instructions.Command.new(
            "Write the highlighted relative path beginning from the current working directory %s (%d/%d)" % [
                (self._target_paths[self._target_index][0] as Path).as_string(),
                self._target_index + 1,
                self._target_paths.size()
            ]
        ))
        self._inst.render()
        self._target_hl = self._file_tree.hl_server.push_color_to_tree_nodes(
            Color.BLUE, new_origin, self._target_paths[self._target_index][1] as Path
        )

        if new_origin.as_string() != old_origin.as_string():
            await GVSGlobals.wait(1)
            self._file_tree.change_cwd(new_origin, old_origin)
            self._viewport.move_cam_to(
                self._file_tree.node_rel_pos_from_path(new_origin)
            )
            await GVSGlobals.wait(2)



    self._inst.render()


func finish() -> void:
    assert(self._target_hl < 0)
    if self._good_hl >= 0:
        self._file_tree.hl_server.pop_id(self._good_hl)
    if self._bad_hl >= 0:
        self._file_tree.hl_server.pop_id(self._bad_hl)

    self._inst.remove_all()

    self.completed.emit(
        preload("res://visualfs/narrator/lesson/completion.gd").new()
    )
    assert(
        self.get_reference_count() == 1,
        "Not all references to writing_relative_paths removed before checkpoint exit."
    )
