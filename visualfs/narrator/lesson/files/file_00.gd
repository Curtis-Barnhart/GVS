extends "res://visualfs/narrator/lesson/checkpoint.gd"

const UtilString = GVSClassLoader.shared.Strings
const FileList = GVSClassLoader.visualfs.FileList
const Path = GVSClassLoader.gvm.filesystem.Path
const File = GVSClassLoader.visual.file_nodes.BaseNode
const Menu = GVSClassLoader.visual.buttons.CircleMenu
const FileReader = GVSClassLoader.visual.FileReader
const FileWriter = GVSClassLoader.visual.FileWriter
const GPopup = GVSClassLoader.visual.GVSPopup

var _first_file := Path.new(["file0"])
var _file_list: FileList


func start(needs_context: bool) -> void:
    # Create a new file list (and manager) and add it to the drag viewport
    # so that we can retrieve it and its children later.
    self._file_list = FileList.make_new()
    self._viewport.add_to_scene(self._file_list)
    self._file_list.name = "FileList"
    
    # Connect file list to manager and add a file
    self._fs_man.created_file.connect(self._file_list.add_file)
    self._fs_man.removed_file.connect(self._file_list.remove_file)
    self._fs_man.create_file(self._first_file)
    var file_written := self._fs_man.write_file(self._first_file, "hello world")
    assert(file_written, "Could not write to the file we just created.")
    var file_vis: File = self._file_list.get_file(self._first_file)
    assert(file_vis != null, "Could not find file in FileList that we just made.")
    
    # Make sure continue button is disabled at start and only enables
    # after the user has read the file
    self._next_button.pressed.connect(self.finish)
    self._file_list.file_clicked.connect(self.menu_popup)
    
    self._text_display.text = UtilString.make_article(
        [
            "What is a File?",
            [
                "How does your computer remember anything?",
                "How does it know what images you have,",
                "or what music you listened to last?",
                "How does it know what tabs you had opened in your web browser?",
            ],
            [
                "The answer to all of these questions is [color=steel blue]files[/color].",
                "Files are storage containers where your computer puts anything",
                "it needs to remember for a long amount of time.",
            ],
            [
                "To complete this section,",
                "all you need to do is [color=steel blue]read[/color],",
                "or look at, the contents of a file,",
                "represented by the little icon on the left side of the screen.",
                "First, click on the icon to open its action menu.",
                "Then, select the action to read the file,",
                "represented by an image of a file and an eye.",
            ],
            [
                "On selecting this action,",
                "the file contents will be displayed.",
                "Continue by clicking anywhere outside of this display,",
                "and then click the continue button below.",
            ]
        ]
    )


func menu_popup(path: Path) -> void:
    var file_vis: File = self._file_list.get_file(path)

    var menu: Menu = Menu.make_new()
    var f0 := Sprite2D.new()
    f0.texture = load("res://visual/assets/file_read.svg")
    menu.add_child(f0)
    f0 = Sprite2D.new()
    f0.texture = load("res://visual/assets/file_write.svg")
    menu.add_child(f0)
    menu.position = file_vis.get_viewport().get_screen_transform() \
                    * file_vis.get_global_transform_with_canvas() \
                    * Vector2.ZERO
    menu.popup(file_vis)
    
    menu.menu_closed.connect(
        func (x: int) -> void:
            match x:
                0:
                    self.file_read_popup(path)
                1:
                    self.file_write_popup(path)
    )


func file_read_popup(path: Path) -> void:
    var file_vis: File = self._file_list.get_file(path)
    var reader := FileReader.make_new()
    var popup := GPopup.make_into_popup(reader)
    popup.position = file_vis.get_viewport().get_screen_transform() \
                    * file_vis.get_global_transform_with_canvas() \
                    * Vector2.ZERO
    reader.load_text(self._fs_man.read_file(path))
    popup.closing.connect(func () -> void: self._next_button.disabled = false)


func file_write_popup(path: Path) -> void:
    var file_vis: File = self._file_list.get_file(path)
    var writer := FileWriter.make_new()
    var popup := GPopup.make_into_popup(writer)
    popup.position = file_vis.get_viewport().get_screen_transform() \
                    * file_vis.get_global_transform_with_canvas() \
                    * Vector2.ZERO
    writer.load_text(self._fs_man.read_file(path))
    
    writer.write.connect(
        func (text: String) -> void:
            var written: bool = self._fs_man.write_file(path, text)
            assert(written)
    )
    writer.quit.connect(popup.close_popup)


func finish() -> void:
    self.completed.emit(
        preload("res://visualfs/narrator/lesson/files/file_01.gd").new()
    )
    assert(
        self.get_reference_count() == 1,
        "Not all references to file_00 removed before checkpoint exit."
    )
