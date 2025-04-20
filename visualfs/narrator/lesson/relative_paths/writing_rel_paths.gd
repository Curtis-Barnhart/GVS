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
        "Write the path to the first highlighted location from the cwd {}"
    ))
    self._inst.render()

    var first_cwd: Path = self._target_paths[self._target_index][0]
    self._target_hl = self._file_tree.hl_server.push_color_to_tree_nodes(
        Color.DARK_BLUE,
        first_cwd,
        self._target_paths[self._target_index][1] as Path
    )
    
    self._file_tree.cwd_text = preload("res://visual/assets/cwd_open.svg")
    await GVSGlobals.wait(1)
    self._file_tree.change_cwd(first_cwd, Path.ROOT)
    self._viewport.move_cam_to(
        self._file_tree.node_rel_pos_from_path(first_cwd)
    )
    await GVSGlobals.wait(2)


    self._next_button.pressed.connect(self.finish)


func _on_user_path(s: String) -> void:
    var path: Path
    if s.begins_with("/"):
        path = null
    else:
        path = Path.new(s.split("/", false))

    #self._suberrors_analyze(path, s)
    self._validate_user_path(path)


var _errs: Dictionary[String, Instructions.Command] = {
    "slash": null,
    "dir_contains": null,
    "file_contains": null,
    "wrong_way": null,
}
func _suberrors_analyze(user_path: Path, user_str: String) -> void:
    var ancestor: Path = self._fs_man.real_ancestry(user_path)
    var target_p: Path = self._target_paths[self._target_index]
    var is_bad: bool = not self._fs_man.contains_path(user_path)
    var first_bad: Path = null
    var more_bad: bool = false
    if is_bad:
        var file_building: GStreams.StreamType = user_path.all_slices().filter(
            func (p: Path) -> bool: return not self._fs_man.contains_path(p)
        )
        first_bad = file_building.next()
        more_bad = file_building.size() > 0

    # See if the user started their path without a leading slash
    if user_str != "" and not user_str.begins_with("/"):
        if self._errs["no_slash"] == null:
            self._errs["no_slash"] = Com.new("Your path does not begin with a '/'")
            self._inst.get_command(-1).add_command(self._errs["no_slash"])
            self._inst.render()
    elif self._errs["no_slash"] != null:
        self._inst.remove_command_ref(self._errs["no_slash"])
        self._errs["no_slash"] = null
        self._inst.render()

    # See if the user thinks a directory contains something it doesn't
    if (
        more_bad
        and not self._fs_man.contains_file(ancestor)
    ):
        if self._errs["dir_contains"] == null:
            self._errs["dir_contains"] = Com.new(
                "'%s' is a valid path, but '%s' is not a valid location contained in that directory" % [
                    first_bad.base().as_string(), first_bad.last()
                ]
            )
            self._inst.get_command(-1).add_command(self._errs["dir_contains"])
        else:
            self._errs["dir_contains"].change_text(
                "'%s' is a valid path, but '%s' is not a valid location contained in that directory" % [
                    first_bad.base().as_string(), first_bad.last()
                ]
            )
        self._inst.render()
    elif self._errs["dir_contains"] != null:
        self._inst.remove_command_ref(self._errs["dir_contains"])
        self._errs["dir_contains"] = null
        self._inst.render()

    # See if a user thinks a file contains something (it can't)
    if (
        is_bad
        and self._fs_man.contains_file(ancestor)
    ):
        if self._errs["file_contains"] == null:
            self._errs["file_contains"] = Com.new(
                "'%s' is a file, and cannot contain another object '%s'" % [
                    first_bad.base().as_string(), first_bad.last()
                ]
            )
            self._inst.get_command(-1).add_command(self._errs["file_contains"])
        else:
            self._errs["file_contains"].change_text(
                "'%s' is a file, and cannot contain another object '%s'" % [
                    first_bad.base().as_string(), first_bad.last()
                ]
            )
        self._inst.render()
    elif self._errs["file_contains"] != null:
        self._inst.remove_command_ref(self._errs["file_contains"])
        self._errs["file_contains"] = null
        self._inst.render()

    # See if the user has written a valid path that diverges from where they ought to go
    if (
        ancestor.common_with(target_p).as_string() != ancestor.as_string()
    ):
        var departs: Path = ancestor.all_slices() \
                                    .reverse() \
                                    .take_while(func (p: Path) -> bool: 
                                        var r := self._fs_man.reduce_path(p)
                                        return r.common_with(target_p).as_string() != r.as_string()) \
                                    .reverse() \
                                    .next()
        if self._errs["wrong_way"] == null:
            self._errs["wrong_way"] = Com.new(
                "'%s' is part of the path to your target, but '%s' starts heading in the wrong direction" % [
                    departs.base().as_string(), departs.last()
                ]
            )
            self._inst.get_command(-1).add_command(self._errs["wrong_way"])
            self._inst.render()
        else:
            self._errs["wrong_way"].change_text(
                "'%s' is part of the path to your target, but '%s' starts heading in the wrong direction" % [
                    departs.base().as_string(), departs.last()
                ]
            )
            self._inst.render()
    elif self._errs["wrong_way"] != null:
        self._inst.remove_command_ref(self._errs["wrong_way"])
        self._errs["wrong_way"] = null
        self._inst.render()


func _suberrors_remove_all() -> void:
    for err: String in self._errs.keys():
        self._inst.remove_command_ref(self._errs[err])
    self._inst.render()


## [param p]: null iff user started path with /
func _validate_user_path(p: Path) -> void:
    # the _target_index member changes if _user_answered_correctly triggered
    var highlight_target: int = self._target_index
    var p_abs_ancestor: Path

    if p == null:
        p_abs_ancestor = Path.ROOT
    else:
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

    if self._good_hl >= 0:
        self._file_tree.hl_server.pop_id(self._good_hl)
    if self._bad_hl >= 0:
        self._file_tree.hl_server.pop_id(self._bad_hl)

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
            "write the path that is highlighted"
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
        "Not all references to practicing_writing_paths removed before checkpoint exit."
    )
