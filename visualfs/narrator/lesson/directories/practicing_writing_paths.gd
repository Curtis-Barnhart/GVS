extends "res://visualfs/narrator/lesson/checkpoint.gd"

const Path = GVSClassLoader.gvm.filesystem.Path
const UtilString = GVSClassLoader.shared.scripts.Strings
const FileList = GVSClassLoader.visualfs.FileList
const FileTree = GVSClassLoader.visual.FileTree
const TNode = GVSClassLoader.visual.file_nodes.TreeNode

var _file_tree: FileTree
var _highlight_id: int = -1

var _target_paths: Array[Path] = [
    Path.new(["school"]),
    Path.new(["work"])
]
var _target_index: int = 0


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
    
    var path_label := RichTextLabel.new()
    self._right_panel.add_child(path_label)
    path_label.name = "PathLabel"


func start(needs_context: bool) -> void:
    if needs_context:
        self.context_build()
    
    self._file_tree = self._viewport.node_from_scene("FileTree")
    self._right_panel.get_node("PathLabel").queue_free()
    
    self._text_display.text = UtilString.make_article(
        [
            "Practice writing paths!",
            [
                "write something"
            ],
        ]
    )


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
