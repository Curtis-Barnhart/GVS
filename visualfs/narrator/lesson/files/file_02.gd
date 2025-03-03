extends "res://visualfs/narrator/lesson/checkpoint.gd"

const UtilString = GVSClassLoader.shared.Strings
const FileList = GVSClassLoader.visualfs.FileList
const Path = GVSClassLoader.gvm.filesystem.Path
const File = GVSClassLoader.visual.file_nodes.File
const Menu = GVSClassLoader.visual.buttons.CircleMenu
const FileReader = GVSClassLoader.visual.FileReader
const GPopup = GVSClassLoader.visual.popups.GVSPopup
const FileWriter = GVSClassLoader.visual.FileWriter

var _files := [
    Path.new(["file0.txt"]),
    Path.new(["file1.txt"]),
    Path.new(["file2.txt"]),
    Path.new(["file3.txt"])
]
var _file_list: FileList


func start() -> void:
    self._text_display.text = UtilString.make_article(
        [
            "Multiple files",
            [
                "Write 'first' to file0.txt",
                "'second' to file1.txt, 'third' to file2.txt,",
                "and 'fourth' to file3.txt."
            ],
        ]
    )
    
    self._file_list = self._viewport.node_from_scene("FileList")

    for path: Path in self._files.slice(1):
        self._fs_man.create_file(path)
        await GVSGlobals.wait(1)

    for path: Path in self._files:
        var vfile: File = self._file_list.get_file(path)
        vfile.connect_to_press(self.menu_popup_factory(path))


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
                self.check_finished()
        )
        writer.quit.connect(popup.close_popup)


func check_finished() -> void:
    if (
        self._fs_man.read_file(self._files[0]).strip_edges() == "first"
        and self._fs_man.read_file(self._files[1]).strip_edges() == "second"
        and self._fs_man.read_file(self._files[2]).strip_edges() == "third"
        and self._fs_man.read_file(self._files[3]).strip_edges() == "fourth"
    ):
        self._next_button.disabled = false


func finish() -> void:
    self.completed.emit(load("res://visualfs/narrator/lesson/completion.gd").new(
        self._fs_man, self._next_button, self._text_display, self._viewport
    ))
