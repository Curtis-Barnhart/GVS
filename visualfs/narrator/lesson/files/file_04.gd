extends "res://visualfs/narrator/lesson/checkpoint.gd"

const UtilString = GVSClassLoader.shared.Strings
const FileList = GVSClassLoader.visualfs.FileList
const Path = GVSClassLoader.gvm.filesystem.Path
const File = GVSClassLoader.visual.file_nodes.File
const Menu = GVSClassLoader.visual.buttons.CircleMenu
const GPopup = GVSClassLoader.visual.popups.GVSPopup
const FileReader = GVSClassLoader.visual.FileReader
const FileWriter = GVSClassLoader.visual.FileWriter
const FCreateInput = GVSClassLoader.visual.SimpleInput

var _file_list: FileList


func start() -> void:
    self._text_display.text = UtilString.make_article(
        [
            "Deleting Files",
            [
                "delete a file",
            ],
        ]
    )
    
    self._file_list = self._viewport.node_from_scene("FileList")
    self._file_list.file_clicked.connect(self.menu_popup)
    self._next_button.pressed.connect(self.finish)


func menu_popup(file_path: Path) -> void:
    var menu: Menu = Menu.make_new()
    var f0 := Sprite2D.new()
    var file_vis: File = self._file_list.get_file(file_path)
    f0.texture = load("res://icon.svg")
    menu.add_child(f0)
    f0 = Sprite2D.new()
    f0.texture = load("res://icon.svg")
    menu.add_child(f0)
    f0 = Sprite2D.new()
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
                    self.file_read_popup(file_path)
                1:
                    self.file_write_popup(file_path)
                2:
                    self.create_file_flow(file_vis)
                3:
                    self.delete_file_flow(file_path)
    )


func delete_file_flow(path: Path) -> void:
    self._fs_man.remove_file(path)
    self._next_button.disabled = false


func create_file_flow(where: File) -> void:
    # Popup file creation menu
    var fname_input := FCreateInput.make_new()
    var fname_popup := GPopup.make_into_popup(
        fname_input,
        where.get_viewport().get_screen_transform() \
            * where.get_global_transform_with_canvas() \
            * Vector2.ZERO
    )
    fname_input.setup("What do you want to name the file?")
    
    fname_input.user_cancelled.connect(fname_popup.close_popup)
    fname_input.user_entered.connect(
        func (msg: String) -> void:
            self._fs_man.create_file(Path.new([msg]))
            fname_popup.close_popup()
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
            var written: bool = self._fs_man.write_file(path, text)
            assert(written)
    )
    writer.quit.connect(popup.close_popup)


func finish() -> void:
    self.completed.emit(load("res://visualfs/narrator/lesson/files/file_05.gd").new(
        self._fs_man, self._next_button, self._text_display, self._viewport
    ))
    assert(
        self.get_reference_count() == 1,
        "Not all references to file_04 removed before checkpoint exit."
    )
