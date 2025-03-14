extends "res://visualfs/narrator/lesson/checkpoint.gd"

const UtilString = GVSClassLoader.shared.Strings
const FileList = GVSClassLoader.visualfs.FileList
const FileTree = GVSClassLoader.visual.FileTree
const Path = GVSClassLoader.gvm.filesystem.Path
const File = GVSClassLoader.visual.file_nodes.BaseNode
const Menu = GVSClassLoader.visual.buttons.CircleMenu
const GPopup = GVSClassLoader.visual.GVSPopup
const FileReader = GVSClassLoader.visual.FileReader
const FileWriter = GVSClassLoader.visual.FileWriter
const FCreateInput = GVSClassLoader.visual.SimpleInput

var _file_tree: FileTree


func start() -> void:    
    await self.remove_old_files()
    self._viewport.node_from_scene("FileList").queue_free()
    await GVSGlobals.wait(0.5)
    
    # Create file tree object in drag viewport connected to the fs_manager
    self._file_tree = FileTree.make_new()
    self._file_tree.name = "FileTree"
    self._viewport.add_to_scene(self._file_tree)
    self._fs_man.created_dir.connect(self._file_tree.create_node_dir)
    self._fs_man.created_file.connect(self._file_tree.create_node_file)
    self._fs_man.removed_dir.connect(self._file_tree.remove_node)
    self._fs_man.removed_file.connect(self._file_tree.remove_node)
    self._next_button.disabled = false
    self._next_button.pressed.connect(self.section2)

    self._text_display.text = UtilString.make_article(
        [
            "Finding Files... the Smart Way",
            [
                "Let's introduce a new way of finding files.",
                "It might seem more complicated at first,",
                "but it uses a system of organization that",
                "allows us to find specific files",
                "even when we are surrounded by a multitude of information.",
            ],
            [
                "This system of organization is similar to finding your way",
                "using directions given by a map on your phone.",
                "When you use a map on your phone to get directions",
                "to, say, Blenders in the Grass,",
                "your phone doesn't just tell you,",
                "\"Ah, sure thing, just head to 1046-F Coast Village Road,\"",
                "and leave the rest up to you!",
                "Instead, it gives you a series of instructions -",
                "\"First, turn right onto Cold Springs.",
                "Next, take a left on Sycamore Canyon...\"",
                "By only telling you the very next road you need to turn on,",
                "it makes finding Blenders simple.",
            ],
            [
                "In the same way, this new system of file organization",
                "enables you to easily find files by only looking for",
                "the 'next turn' at any given moment.",
                "By following each next 'direction',",
                "you don't need to have the file's location memorized,",
                "and can instead follow instruction that bring you closer and closer",
                "to its final location."
            ],
        ]
    )
    await GVSGlobals.wait(0.5)
    self._fs_man.create_file(Path.new(["file0"]))
    self._fs_man.create_file(Path.new(["file1"]))
    self._fs_man.create_file(Path.new(["file2"]))


func section2() -> void:
    self._next_button.pressed.disconnect(self.section2)
    self._next_button.pressed.connect(self.finish)
    self._next_button.disabled = true
    self._file_tree.file_clicked.connect(self.file_clicked)
    self._text_display.text = UtilString.make_article(
        [
            "Finding Files... the Smart Way",
            [
                "We will start with a simple example,",
                "where there is only a single 'turn' to take.",
                "In this section, you will see a solid blue icon labelled '/'",
                "that represents your 'starting point'.",
                "You'll also notice blue lines connecting it to several files.",
                "You can think of these blue lines as 'roads' - they connect",
                "the different 'places' in your computer and allow you to",
                "navigate between them.",
                "Click on your 'next turn' (in this case, your destination),",
                "which is a file called 'file2'.",
                "When you click on it, you'll see the blue line turn red.",
                "This will be helpful when your 'route' contains multiple turns,",
                "and will let you see the entire route you've taken so far.",
                "You can complete this section once you've selected 'file2'."
            ],
        ]
    )


func file_clicked(file_path: Path) -> void:
    if file_path.as_string() == "/file2":
        self._file_tree.file_clicked.disconnect(self.file_clicked)
        self._file_tree.highlight_path(Path.ROOT, file_path)
        self._next_button.disabled = false


func remove_old_files() -> void:
    var old_files: Array = self._fs_man.read_files_in_dir(Path.ROOT)
    old_files.reverse()
    
    var t: float = 0.25
    for old_file: Path in old_files:
        self._fs_man.remove_file(old_file)
        await GVSGlobals.wait(t)
        t = max(0.95 * t, 1.0/16)


func finish() -> void:
    self._file_tree.highlight_path(Path.ROOT, Path.ROOT)
    self.completed.emit(
        preload("res://visualfs/narrator/lesson/directories/directory_01.gd").new()
    )
    assert(
        self.get_reference_count() == 1,
        "Not all references to file_05 removed before checkpoint exit."
    )
