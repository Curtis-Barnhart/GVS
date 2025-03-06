extends "res://visualfs/narrator/lesson/checkpoint.gd"

const UtilString = GVSClassLoader.shared.Strings
const FileList = GVSClassLoader.visualfs.FileList
const Path = GVSClassLoader.gvm.filesystem.Path
const File = GVSClassLoader.visual.file_nodes.BaseNode
const Menu = GVSClassLoader.visual.buttons.CircleMenu
const FileReader = GVSClassLoader.visual.FileReader
const GPopup = GVSClassLoader.visual.GVSPopup
const FileWriter = GVSClassLoader.visual.FileWriter

var _first_file := Path.new(["file0"])
var _file_list: FileList


func start() -> void:
    self._file_list = self._viewport.node_from_scene("FileList")
    
    var file_vis: File = self._file_list.get_file(self._first_file)
    assert(file_vis != null, "Could not find file in FileList that we just made.")
    
    # Make sure continue button is disabled at start and only enables
    # after the user has read the file
    self._next_button.pressed.connect(self.finish)
    self._file_list.file_clicked.connect(self.menu_popup)
    
    self._text_display.text = UtilString.make_article(
        [
            "Writing to a File",
            [
                "It would be rather silly if you could only read a file though.",
                "You can also replace the contents of a file,",
                "which is called [color=steel blue]writing[/color] to it.",
            ],
            [
                "To complete this section, write any changes to the file.",
                "To write to a file, click on it to open its action menu.",
                "Select the action to write to the file,",
                "represented by an image of a file and a pencil.",
                "Click the screen that pops up,",
                "and you will be able to write text into it.",
                "When you are done, click the 'write' button",
                "to write (or save) your changes to the file.",
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
            var old_text: String = self._fs_man.read_file(path)
            var written: bool = self._fs_man.write_file(path, text)
            assert(written)
            if old_text != text:
                self._next_button.disabled = false
    )
    writer.quit.connect(popup.close_popup)


func finish() -> void:
    self.completed.emit(
        preload("res://visualfs/narrator/lesson/files/file_02.gd").new(
            self._fs_man, self._next_button, self._text_display, self._viewport
        )
    )
    assert(
        self.get_reference_count() == 1,
        "Not all references to file_01 removed before checkpoint exit."
    )
