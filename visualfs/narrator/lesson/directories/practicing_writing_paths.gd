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

var _target_paths: Array[Path] = [
    Path.new(["projects", "school", "homework_1"]),
    Path.new(["pictures", "nature", "butterflies"]),
    Path.new(["projects", "movie"])
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
    
    var path_label := RichTextLabel.new()
    self._right_panel.add_child(path_label)
    path_label.name = "PathLabel"
    
    self._inst.remove_all()
    self._inst.render()


func start(needs_context: bool) -> void:
    if needs_context:
        self.context_build()
    
    self._file_tree = self._viewport.node_from_scene("FileTree")
    self._right_panel.get_node("PathLabel").queue_free()
    
    self._text_display.text = UtilString.make_article(
        [
            "Practice writing paths!",
            [
                "Now it's time for you to practice the reverse -",
                "writing out a path to a file given its location.",
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
    
    self._inst.add_command(Instructions.Command.new(
        "Write the path to the first highlighted location"
    ))
    self._inst.render()
    
    self._target_hl = self._file_tree.hl_server.push_color_to_tree_nodes(
        Color.DARK_BLUE, Path.ROOT, self._target_paths[self._target_index]
    )
    
    self._next_button.pressed.connect(self.finish)


func _on_user_path(s: String) -> void:
    var path: Path
    if not s.begins_with("/"):
        path = Path.ROOT
    else:
        path = Path.new(s.split("/", false))
    
    self._suberrors_analyze(path, s)
    self._validate_user_path(path)


var _errs: Dictionary[String, Instructions.Command] = {
    "no_slash": null,
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


func _validate_user_path(p: Path) -> void:
    var target: Path = self._target_paths[self._target_index]
    var simplified: Path = self._fs_man.reduce_path(p)
    var ancestor: Path = self._fs_man.real_ancestry(p)
    var highlight_target: int = self._target_index
        
    if simplified == null:
        simplified = self._fs_man.reduce_path(ancestor)
    else:
        if simplified.as_string() == target.as_string():
            self._suberrors_remove_all()
            self._user_answered_correctly()

    self._highlight_user_path(ancestor, highlight_target)


func _highlight_user_path(p: Path, target_index: int) -> void:
    var target: Path = self._target_paths[target_index]
    var simplified: Path = self._fs_man.reduce_path(p)
    var correct: String = simplified.common_with(target).as_string()
    var simplest_correct: Path = p.all_slices().reverse().filter(func (sub: Path) -> bool:
        return self._fs_man.reduce_path(sub).as_string() == correct
    ).next()
    var incorrect: Path = p.slice(simplest_correct.size())
    
    if self._good_hl >= 0:
        self._file_tree.hl_server.pop_id(self._good_hl)
    if self._bad_hl >= 0:
        self._file_tree.hl_server.pop_id(self._bad_hl)
    
    self._good_hl = self._file_tree.hl_server.push_color_to_tree_nodes(Color.GREEN, Path.ROOT, simplest_correct)
    self._bad_hl = self._file_tree.hl_server.push_color_to_tree_nodes(Color.RED, simplest_correct, incorrect)


func _user_answered_correctly() -> void:
    self._target_index += 1
    self._inst.get_command(-1).set_fulfill(true)
    self._file_tree.hl_server.pop_id(self._target_hl)
    
    if self._target_index == self._target_paths.size():
        self._next_button.disabled = false
        self._line_edit.text_changed.disconnect(self._on_user_path)
        # TODO: print out good job message
    else:
        self._inst.add_command(Instructions.Command.new(
            "Write the path to the %s highlighted location" % ["", "second", "third"][self._target_index]
        ))
        self._target_hl = self._file_tree.hl_server.push_color_to_tree_nodes(
            Color.DARK_BLUE, Path.ROOT, self._target_paths[self._target_index]
        )

    self._inst.render()


func finish() -> void:
    if self._target_hl >= 0:
        self._file_tree.hl_server.pop_id(self._target_hl)
    if self._good_hl >= 0:
        self._file_tree.hl_server.pop_id(self._good_hl)
    if self._bad_hl >= 0:
        self._file_tree.hl_server.pop_id(self._bad_hl)
    
    self._inst.remove_all()
    
    self.completed.emit(
        preload("res://visualfs/narrator/lesson/relative_paths/introducing_rel_paths.gd").new()
    )
    assert(
        self.get_reference_count() == 1,
        "Not all references to practicing_writing_paths removed before checkpoint exit."
    )
