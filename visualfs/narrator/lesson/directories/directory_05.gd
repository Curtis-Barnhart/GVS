extends "res://visualfs/narrator/lesson/checkpoint.gd"

const UtilString = GVSClassLoader.shared.Strings
const FileTree = GVSClassLoader.visual.FileTree
const Path = GVSClassLoader.gvm.filesystem.Path

var _file_tree: FileTree
var _relative_node: Array[Path] = [
    Path.ROOT,
    Path.ROOT
]
var _target_nodes: Array[Path] = [
    Path.ROOT,
    Path.ROOT
]
var _target_index: int = 0
var _path_label := Label.new()


func context_build() -> void:
    var ft := FileTree.make_new()
    ft.name = "FileTree"
    self._viewport.add_to_scene(ft)
    self._fs_man.created_dir.connect(ft.create_node_dir)
    self._fs_man.created_file.connect(ft.create_node_file)
    self._fs_man.removed_dir.connect(ft.remove_node)
    self._fs_man.removed_file.connect(ft.remove_node)

    self._fs_man.create_file(Path.new(["file0"]))
    self._fs_man.create_file(Path.new(["file1"]))
    self._fs_man.create_file(Path.new(["file2"]))
    self._fs_man.create_dir(Path.new(["directory0"]))
    self._fs_man.create_dir(Path.new(["directory1"]))
    self._fs_man.create_file(Path.new(["directory0", "file0"]))
    self._fs_man.create_file(Path.new(["directory0", "file1"]))
    self._fs_man.create_file(Path.new(["directory1", "file0"]))
    self._fs_man.create_file(Path.new(["directory1", "file1"]))
    self._fs_man.create_dir(Path.new(["directory0", "subdirectory0"]))
    self._fs_man.create_dir(Path.new(["directory0", "subdirectory1"]))
    self._fs_man.create_file(Path.new(["directory0", "subdirectory0", "file0"]))
    self._fs_man.create_file(Path.new(["directory0", "subdirectory1", "file0"]))
    self._fs_man.create_file(Path.new(["directory0", "subdirectory0", "file1"]))
    self._fs_man.create_file(Path.new(["directory0", "subdirectory1", "file1"]))


func start(needs_context: bool) -> void:
    if needs_context:
        self.context_build()
    
    self._file_tree = self._viewport.node_from_scene("FileTree")
    self._next_button.pressed.connect(self.change_the_cwd)
    
    #self._path_label.add_theme_font_override("font", load("res://shared/JetBrainsMonoNerdFontMono-Regular.ttf") as Font)
    #self._path_label.add_theme_font_size_override("font_size", 48)
    #self._path_label.add_theme_stylebox_override("normal", load("res://shared/TextBox.tres") as StyleBox)
    ## TODO: At some point this will have to be done based on the size of the font
    #self._path_label.size.x = 1000
    #self._path_label.position = Vector2(-500, -160)
    #self._path_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    
    self._text_display.text = UtilString.make_article(
        [
            "Relative Paths",
            [
                "This whole time, we've described a path as a set of directions",
                "going from the very top of the file system",
                "down to a particular file or directory.",
                "But what if the directions start from somewhere else?",
            ],
        ]
    )


func change_the_cwd() -> void:
    self._file_tree.change_cwd(Path.new(["directory0"]), Path.ROOT)
    self._viewport.move_cam_to(self._file_tree.node_rel_pos_from_path(Path.new(["directory0"])))

    self._text_display.text = UtilString.make_article(
        [
            "Relative Paths",
            [
                "What if we're starting from the location '/directory0'?",
                "If we want to give directions "
            ],
        ]
    )


func finish() -> void:
    self._file_tree.highlight_path(Path.ROOT, Path.ROOT)
    self.completed.emit(
        preload("res://visualfs/narrator/lesson/directories/directory_06.gd").new()
    )
    assert(
        self.get_reference_count() == 1,
        "Not all references to directory_05 removed before checkpoint exit."
    )
