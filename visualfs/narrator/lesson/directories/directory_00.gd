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
    self._viewport.node_from_scene("FileList").queue_free()
    for old_file: Path in self._fs_man.read_files_in_dir(Path.ROOT):
        self._fs_man.remove_file(old_file)
    
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
                "I'm going to make about a hundred different files,",
                "and I'm going to ask you to delete a certain one",
                "just like in the last section.",
                "This time, however, we're going to use a system of directions",
                "that will help you locate it with ease.",
                "Each next direction will get you closer to the file,",
                "just like each next direction on a GPS",
                "takes you closer to your destination when you travel."
            ],
            [
                "You should notice that there are other icons",
                "besides just the file icons now.",
                "These other icons "
            ],
        ]
    )


func menu_popup(file_path: Path) -> void:
    var menu: Menu = Menu.make_new()
    var f0 := Sprite2D.new()
    var file_vis: File = self._file_tree.get_file(file_path)
    f0.texture = load("res://visual/assets/file_read.svg")
    menu.add_child(f0)
    f0 = Sprite2D.new()
    f0.texture = load("res://visual/assets/file_write.svg")
    menu.add_child(f0)
    f0 = Sprite2D.new()
    f0.texture = load("res://visual/assets/file_new.svg")
    menu.add_child(f0)
    f0 = Sprite2D.new()
    f0.texture = load("res://visual/assets/file_delete.svg")
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
    var file_vis: File = self._file_tree.get_file(path)
    var reader := FileReader.make_new()
    var popup := GPopup.make_into_popup(reader)
    popup.position = file_vis.get_viewport().get_screen_transform() \
                    * file_vis.get_global_transform_with_canvas() \
                    * Vector2.ZERO
    reader.load_text(self._fs_man.read_file(path))


func file_write_popup(path: Path) -> void:
    var file_vis: File = self._file_tree.get_file(path)
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
    self._next_button.text = "Continue"
    self.completed.emit(
        preload("res://visualfs/narrator/lesson/completion.gd").new(
            self._fs_man, self._next_button, self._text_display, self._viewport
        )
    )
    assert(
        self.get_reference_count() == 1,
        "Not all references to file_05 removed before checkpoint exit."
    )


# Fake file generation
const prefixes := ["report", "document", "image", "backup", "log", "summary", "presentation", "data", "audio", "video"]
const suffixes := ["v1", "final", "draft", "backup", "edited", "compressed"]
const extensions := ["txt", "pdf", "png", "jpg", "mp3", "mp4", "zip", "docx", "csv", "json"]


func generate_fake_filename() -> String:
    var prefix: String = prefixes[randi() % prefixes.size()]
    var middle: String = str(randi() % 1000) if randf() < 0.5 else suffixes[randi() % suffixes.size()]
    var extension: String = extensions[randi() % extensions.size()]
    return prefix + "_" + middle + "." + extension


func make_fake_files(count: int) -> void:
    var t: float = 0.25
    for _x in range(count):
        self._fs_man.create_file(Path.new([self.generate_fake_filename()]))
        await GVSGlobals.wait(t)
        t = max(0.95*t, 1.0/16)
