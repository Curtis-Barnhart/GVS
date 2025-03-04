extends "res://visualfs/narrator/lesson/checkpoint.gd"

const UtilString = GVSClassLoader.shared.Strings
const FileList = GVSClassLoader.visualfs.FileList
const Path = GVSClassLoader.gvm.filesystem.Path
const File = GVSClassLoader.visual.file_nodes.BaseNode
const Menu = GVSClassLoader.visual.buttons.CircleMenu
const FileReader = GVSClassLoader.visual.FileReader
const GPopup = GVSClassLoader.visual.popups.GVSPopup
const FileWriter = GVSClassLoader.visual.FileWriter

var _files: Array[Path] = [
    Path.new(["file0"]),
    Path.new(["file1"]),
    Path.new(["file2"]),
    Path.new(["file3"])
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
    self._next_button.pressed.connect(self.finish)
    self._file_list.file_clicked.connect(self.menu_popup)
    
    for path: Path in self._files.slice(1):
        self._fs_man.create_file(path)
        await GVSGlobals.wait(1)
    


func menu_popup(file_path: Path) -> void:
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
                    self.file_read_popup(file_path)
                1:
                    self.file_write_popup(file_path)
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
    self.completed.emit(
        preload("res://visualfs/narrator/lesson/files/file_03.gd").new(
            self._fs_man, self._next_button, self._text_display, self._viewport
        )
    )
    assert(
        self.get_reference_count() == 1,
        "Not all references to file_02 removed before checkpoint exit."
    )
