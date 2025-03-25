extends "res://visualfs/narrator/lesson/checkpoint.gd"

const Path = GVSClassLoader.gvm.filesystem.Path
const UtilString = GVSClassLoader.shared.Strings
const FileList = GVSClassLoader.visualfs.FileList
const FileTree = GVSClassLoader.visual.FileTree

var _file_tree: FileTree
var _path_label := RichTextLabel.new()


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
                "look at all the new files!"
            ],
        ]
    )
    
    self._right_panel.add_child(self._path_label)
    
    self._path_label.bbcode_enabled = false
    self._path_label.push_font(preload("res://shared/JetBrainsMonoNerdFontMono-Regular.ttf"))
    


func finish() -> void:
    self._file_tree.highlight_path(Path.ROOT, Path.ROOT)
    #self.completed.emit(
        #preload("res://visualfs/narrator/lesson/directories/directory_01.gd").new()
    #)
    assert(
        self.get_reference_count() == 1,
        "Not all references to exploring_paths removed before checkpoint exit."
    )
