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
var _files := [
    Path.new(["This is a file"]),
    Path.new(["data.txt"]),
    Path.new(["picture.png"]),
    Path.new(["main.py"])
]
var _file_list: FileList


func start() -> void:
    self._file_list = self._viewport.node_from_scene("FileList")

    for path: Path in self._files.slice(1):
        self._fs_man.create_file(path)
        await GVSGlobals.wait(1)

    for path: Path in self._files:
        var vfile: File = self._file_list.get_file(path)
        vfile.connect_to_press(self.menu_popup_factory(path))

    self._text_display.text = UtilString.make_article(
        [
            "Multiple files",
            [
                "Here are multiple files at once",
            ],
        ]
    )


func menu_popup_factory(file_path: Path) -> Callable:
    return func() -> void:
        var menu: Menu = Menu.make_new()
        var f0 := Sprite2D.new()
        var file_vis: File = self._file_list.get_file(file_path)
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
                        self.file_read_popup_factory(file_path).call()
                    1:
                        self.file_write_popup_factory(file_path).call()
        )


func file_read_popup_factory(file_path: Path) -> Callable:
    return func () -> void:
        var reader := FileReader.make_new()
        var popup := GPopup.make_into_popup(reader)
        var file_vis: File = self._file_list.get_file(file_path)
        popup.position = file_vis.get_viewport().get_screen_transform() \
                        * file_vis.get_global_transform_with_canvas() \
                        * Vector2.ZERO
        reader.load_text(self._fs_man.read_file(file_path))


func file_write_popup_factory(file_path: Path) -> Callable:
    return func () -> void:
        var writer := FileWriter.make_new()
        var popup := GPopup.make_into_popup(writer)
        var file_vis: File = self._file_list.get_file(file_path)
        popup.position = file_vis.get_viewport().get_screen_transform() \
                        * file_vis.get_global_transform_with_canvas() \
                        * Vector2.ZERO
        writer.load_text(self._fs_man.read_file(file_path))
        
        writer.write.connect(
            func (text: String) -> void:
                var written: bool = self._fs_man.write_file(file_path, text)
                assert(written)
        )
        writer.quit.connect(popup.close_popup)


func finish() -> void:
    self.completed.emit(load("res://visualfs/narrator/lesson/completion.gd").new(
        self._fs_man, self._next_button, self._text_display, self._viewport
    ))
