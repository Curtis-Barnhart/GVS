extends "res://visualfs/narrator/lesson/checkpoint.gd"

const UtilString = GVSClassLoader.shared.Strings
const FileList = GVSClassLoader.visualfs.FileList
const Path = GVSClassLoader.gvm.filesystem.Path
const File = GVSClassLoader.visual.file_nodes.File
const Menu = GVSClassLoader.visual.buttons.CircleMenu
const FileReader = GVSClassLoader.visual.FileReader
const GPopup = GVSClassLoader.visual.popups.GVSPopup
const FileWriter = GVSClassLoader.visual.FileWriter

var _first_file := Path.new(["This is a file"])
var _file_list: FileList


func start() -> void:
    self._file_list = self._viewport.node_from_scene("FileList")
    
    var file_vis: File = self._file_list.get_file(self._first_file)
    assert(file_vis != null, "Could not find file in FileList that we just made.")
    
    # Make sure continue button is disabled at start and only enables
    # after the user has read the file
    self._next_button.pressed.connect(self.finish)
    file_vis.connect_to_press(self.menu_popup)
    
    self._text_display.text = UtilString.make_article(
        [
            "Writing to a File",
            [
                "Here's how you write to a file",
            ],
        ]
    )


func menu_popup() -> void:
    var file_vis: File = self._file_list.get_file(self._first_file)

    var menu: Menu = Menu.make_new()
    var f0 := Sprite2D.new()
    f0.texture = load("res://icon.svg")
    menu.add_child(f0)
    f0 = Sprite2D.new()
    f0.texture = load("res://icon.svg")
    menu.add_child(f0)
    menu.position = file_vis.get_viewport().get_screen_transform() \
                    * file_vis.get_global_transform_with_canvas() \
                    * Vector2.ZERO
    menu.popup(file_vis)
    
    menu.menu_closed.connect(
        func (x: int) -> void:
            match x:
                0:
                    self.file_read_popup()
                1:
                    self.file_write_popup()
    )


func file_read_popup() -> void:
    var file_vis: File = self._file_list.get_file(self._first_file)
    var reader := FileReader.make_new()
    var popup := GPopup.make_into_popup(reader, self._file_list)
    popup.position = file_vis.get_viewport().get_screen_transform() \
                    * file_vis.get_global_transform_with_canvas() \
                    * Vector2.ZERO
    reader.load_text(self._fs_man.read_file(self._first_file))


func file_write_popup() -> void:
    var file_vis: File = self._file_list.get_file(self._first_file)
    var writer := FileWriter.make_new()
    var popup := GPopup.make_into_popup(writer, self._file_list)
    popup.position = file_vis.get_viewport().get_screen_transform() \
                    * file_vis.get_global_transform_with_canvas() \
                    * Vector2.ZERO
    writer.load_text(self._fs_man.read_file(self._first_file))
    
    writer.write.connect(
        func (text: String) -> void:
            var old_text: String = self._fs_man.read_file(self._first_file)
            var written: bool = self._fs_man.write_file(self._first_file, text)
            assert(written)
            if old_text != text:
                self._next_button.disabled = false
    )
    writer.quit.connect(popup.close_popup)


func finish() -> void:
    self.completed.emit(load("res://visualfs/narrator/lesson/completion.gd").new(
        self._fs_man, self._next_button, self._text_display, self._viewport
    ))
