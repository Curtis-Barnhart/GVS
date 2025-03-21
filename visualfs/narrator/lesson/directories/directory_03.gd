extends "res://visualfs/narrator/lesson/checkpoint.gd"

const UtilString = GVSClassLoader.shared.Strings
const FileTree = GVSClassLoader.visual.FileTree
const Path = GVSClassLoader.gvm.filesystem.Path

var _file_tree: FileTree
var _targets: PackedStringArray = [
    "/file0",
    "/directory0/subdirectory1",
    "/directory1/file0",
    "/directory0/subdirectory0/file1",
    "/"
]
var _target_index: int = 0
var _path_label := Label.new()


func start(needs_context: bool) -> void:            
    self._text_display.text = UtilString.make_article(
        [
            "What is a Path?",
            [
                "This way of identifying files by providing a route",
                "to them is pretty handy!",
                "If you had a thousand files to search through,",
                "instead of checking every single one to see if it was",
                "the one you wanted",
                "you could just follow the route exactly to the right one.",
            ],
            [
                "This type of 'route' we use to identify files",
                "is called a [color=steel blue]Path[/color] -",
                "which makes a lot of sense",
                "considering the navigation analogy we've been using.",
                "A Path is written using the forward slash character",
                "[color=steel blue]/[/color] to indicate that the",
                "'next turn' is coming up - that the next word",
                "is going to be the next step of the route to a file.",
                "If I wanted to tell you to find the file which is located by going",
                "to 'directory0', then 'subdirectory1', and lastly to 'file0',",
                "I could just give you the path '/directory0/subdirectory1/file0',",
                "and you would have all the information you need to find it.",
            ],
        ]
    )
    
    self._file_tree = self._viewport.node_from_scene("FileTree")
    self._next_button.disabled = false
    self._next_button.pressed.connect(self.section2)


func section2() -> void:
    self._text_display.text = UtilString.make_article(
        [
            "What is a Path?",
            [
                "The intermediary places which are not themselves files",
                "but contain routing information to other files",
                "are called 'directories',",
                "like the directory in a mall which tells you where",
                "all the stores inside can be located.",
                "A path doesn't have to end at a file -",
                "it could end at a directory as well, like",
                "'/directory0/subdirectory1'.",
            ],
            [
                "One nice thing about the structure of files and directories",
                "is that files can only be contained in a single directory",
                "(In our map example, this means that there is only one road",
                "to get to any given place).",
                "This means that there is only one valid path to any given file,",
                "so you can't have two different paths that end up at the same place.",
            ],
        ]
    )
    self._next_button.pressed.disconnect(self.section2)
    self._next_button.pressed.connect(self.section3)


func section3() -> void:
    self._text_display.text = UtilString.make_article(
        [
            "What is a Path?",
            [
                "To get a little more practice with finding files",
                "and working with paths,",
                "let's have you identify a few more files and directories",
                "based solely on their paths.",
                "During this section, you won't need to click on each",
                "turn along the way - you can just click on the final file",
                "or directory to locate it.",
                "However, if you find it helpful to build the path up piece by piece,",
                "feel free to do so.",
            ],
            [
                "To help you understand paths, I'll add a display at the top",
                "of the file structure in the left window that will display",
                "the path of any file or directory you click on.",
                "Even if the file you clicked on wasn't correct,",
                "you'll be able to see what the path to that file is,",
                "which will help you understand how that path is different",
                "from the one you are looking for.",
                "Click on the file or directory indicated by the following paths",
                "to complete this section:"
            ],
            [
                "/file0"
            ],
        ]
    )
    
    self._file_tree.file_clicked.connect(self.file_clicked)

    self._path_label.add_theme_font_override("font", load("res://shared/JetBrainsMonoNerdFontMono-Regular.ttf") as Font)
    self._path_label.add_theme_font_size_override("font_size", 48)
    self._path_label.add_theme_stylebox_override("normal", load("res://shared/TextBox.tres") as StyleBox)
    # TODO: At some point this will have to be done based on the size of the font
    self._path_label.size.x = 1000
    self._path_label.position = Vector2(-500, -160)
    self._path_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    self._viewport.add_to_scene(self._path_label)

    self._text_display.scroll_following = true
    self._next_button.disabled = true
    self._next_button.pressed.disconnect(self.section3)
    self._next_button.pressed.connect(self.finish)


func file_clicked(file_path: Path) -> void:
    self._file_tree.highlight_path(Path.ROOT, file_path)
    self._path_label.text = file_path.as_string()
    if (
        self._target_index < self._targets.size()
        and file_path.as_string() == self._targets[self._target_index]
    ):
        self._target_index += 1
        if self._target_index == self._targets.size():
            self._next_button.disabled = false
            self._file_tree.highlight_path(Path.ROOT, Path.ROOT)
        else:
            self._text_display.text += UtilString.make_paragraphs(
                [[self._targets[self._target_index]]]
            )


func finish() -> void:
    self._text_display.scroll_following = false
    self.completed.emit(
        preload("res://visualfs/narrator/lesson/directories/directory_04.gd").new()
    )
    assert(
        self.get_reference_count() == 1,
        "Not all references to directory_03 removed before checkpoint exit."
    )
