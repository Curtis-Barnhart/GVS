extends "res://visualfs/narrator/lesson/checkpoint.gd"

const UtilString = GVSClassLoader.shared.Strings
const FileList = GVSClassLoader.visualfs.FileList
const Path = GVSClassLoader.gvm.filesystem.Path
const File = GVSClassLoader.visual.file_nodes.BaseNode
const Menu = GVSClassLoader.visual.buttons.CircleMenu
const GPopup = GVSClassLoader.visual.GVSPopup
const FileReader = GVSClassLoader.visual.FileReader
const FileWriter = GVSClassLoader.visual.FileWriter
const FCreateInput = GVSClassLoader.visual.SimpleInput

var _file_list: FileList
var _current_target: Path


func start(needs_context: bool) -> void:    
    self._file_list = self._viewport.node_from_scene("FileList")
    self._file_list.file_clicked.connect(self.menu_popup)
    self._next_button.pressed.connect(self.finish)
    
    self.make_fake_files(10)
    self.set_current_target()
    self._fs_man.removed_file.connect(self.more_files)
    
    self._text_display.text = UtilString.make_article(
        [
            "Finding Files",
            [
                "Now we're going to explain some shortcomings",
                "of just using names to identify files.",
                "To demonstrate this,",
                "please locate the file",
                "%s." % self._current_target.as_string(false),
                "Delete the file to show that you've located it."
            ],
        ]
    )


func more_files(deleted: Path) -> void:
    if self._current_target.as_string() != deleted.as_string():
        return
    
    await GVSGlobals.wait(2)
    self.make_fake_files(20)
    self.set_current_target()
    self._fs_man.removed_file.disconnect(self.more_files)
    self._fs_man.removed_file.connect(self.even_more_files)
    self._text_display.text = UtilString.make_article(
        [
            "Finding Files",
            [
                "Not bad... but what happens when add a few more files?",
                "Find the file '%s'" % self._current_target.as_string(false),
                "and delete it to show that you've found it."
            ],
        ]
    )


func even_more_files(deleted: Path) -> void:
    if self._current_target.as_string() != deleted.as_string():
        return
    
    await GVSGlobals.wait(2)
    self._next_button.text = "Give up?"
    self._next_button.disabled = false
    self.make_fake_files(70)
    self.set_current_target()
    self._fs_man.removed_file.disconnect(self.even_more_files)
    self._fs_man.removed_file.connect(self.found_everything)
    
    self._text_display.text = UtilString.make_article(
        [
            "Finding Files",
            [
                "One last challenge (this one is optional)...",
                "Find the file '%s'." % self._current_target.as_string(false),
                "and delete it to show that you've found it.",
                "If these seems like an unreasonable task...",
                "then you're understanding the point of the lesson!",
                "Trying to find a single file can feel like",
                "searching for a needle in a haystack.",
                "You can click the continue button to skip this part",
                "if you aren't feeling particularly stubborn,",
                "and we'll move on to examine a better way of organizing files.",
            ],
        ]
    )


func found_everything(deleted: Path) -> void:
    if self._current_target.as_string() != deleted.as_string():
        return
    
    self._next_button.text = "Continue"
    self._fs_man.removed_file.disconnect(self.found_everything)
    
    self._text_display.text = UtilString.make_article(
        [
            "Finding Files",
            [
                "Good job lol."
            ],
        ]
    )


func menu_popup(file_path: Path) -> void:
    var menu: Menu = Menu.make_new()
    var f0 := Sprite2D.new()
    var file_vis: File = self._file_list.get_file(file_path)
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
    self._next_button.text = "Continue"
    self.completed.emit(
        preload("res://visualfs/narrator/lesson/directories/directory_00.gd").new()
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


func set_current_target() -> void:
    var all_files: Array = self._fs_man.read_files_in_dir(Path.ROOT)
    self._current_target = all_files[randi() % all_files.size()]
