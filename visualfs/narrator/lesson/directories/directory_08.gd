extends "res://visualfs/narrator/lesson/checkpoint.gd"

const FManager = GVSClassLoader.gvm.filesystem.Manager
const Path = GVSClassLoader.gvm.filesystem.Path
const FileTree = GVSClassLoader.visual.FileTree
const File = GVSClassLoader.visual.file_nodes.BaseNode
const Dir = GVSClassLoader.visual.file_nodes.TreeNode
const Menu = GVSClassLoader.visual.buttons.CircleMenu
const TreeNode = GVSClassLoader.visual.file_nodes.TreeNode
const GPopup = GVSClassLoader.visual.GVSPopup
const FileReader = GVSClassLoader.visual.FileReader
const FileWriter = GVSClassLoader.visual.FileWriter
const FCreateInput = GVSClassLoader.visual.SimpleInput
const UtilString = GVSClassLoader.shared.Strings

var _file_tree: FileTree


func start(needs_context: bool) -> void:            
    self._file_tree = self._viewport.node_from_scene("FileTree")
    self._file_tree.file_clicked.connect(self.menu_popup)
    self._next_button.pressed.connect(self.finish)
    
    self._text_display.text = UtilString.make_article(
        [
            "Adding, Removing, Reading, and Writing Files and Directories",
            [
                "We spent quite some time earlier explaining how",
                "files are useful tools for storing information",
                "and how you could view, edit, create, and delete them.",
                "We've strayed from that original discussion a little",
                "by really delving deep into how files are organized,",
                "but it's time to reintroduce those concepts we saw earlier.",
            ],
            [
                "Thankfully, these concepts haven't really changed much.",
                "You can still manipulate files just like before.",
                "The only difference is that now you not only deal",
                "with a file's name, but also with its location.",
                "To create a file, click on a directory to open its action menu.",
                "When you select the action to create a file,",
                "it will be created in that directory, that is,",
                "its path will be the path to that directory",
                "plus the name of the file",
                "The same is true of creating new directories."
            ],
            [
                "To complete this section",
            ],
        ]
    )


func menu_settings_file(menu: Menu, file_path: Path) -> void:
    var f0 := Sprite2D.new()
    f0.texture = load("res://visual/assets/file_read.svg")
    menu.add_child(f0)
    f0 = Sprite2D.new()
    f0.texture = load("res://visual/assets/file_write.svg")
    menu.add_child(f0)
    f0 = Sprite2D.new()
    f0.texture = load("res://visual/assets/file_delete.svg")
    menu.add_child(f0)
    
    menu.menu_closed.connect(
        func (x: int) -> void:
            match x:
                0:
                    self.file_read_popup(file_path)
                1:
                    self.file_write_popup(file_path)
                2:
                    self.delete_file_flow(file_path)
    )


func menu_settings_dir(menu: Menu, file_path: Path) -> void:
    var f0 := Sprite2D.new()
    f0.texture = load("res://visual/assets/directory_new.svg")
    menu.add_child(f0)
    f0 = Sprite2D.new()
    f0.texture = load("res://visual/assets/directory_delete.svg")
    menu.add_child(f0)
    f0 = Sprite2D.new()
    f0.texture = load("res://visual/assets/file_new.svg")
    menu.add_child(f0)
    
    f0 = Sprite2D.new()
    if self._file_tree.is_dir_collapsed(file_path):
        f0.texture = load("res://icon.svg")
        menu.add_child(f0)    
    else:
        f0.texture = load("res://icon.svg")
        menu.add_child(f0)    
    
    menu.menu_closed.connect(
        func (x: int) -> void:
            match x:
                0:
                    self.create_dir_flow(file_path)
                1:
                    self.delete_dir_flow(file_path)
                2:
                    self.create_file_flow(file_path)
                3:
                    self.toggle_dir_collapse(file_path)
    )


func menu_popup(file_path: Path) -> void:
    var menu: Menu = Menu.make_new()

    match self._fs_man.contains_type(file_path):
        FManager.filetype.DIR:
            self.menu_settings_dir(menu, file_path)
        FManager.filetype.FILE:
            self.menu_settings_file(menu, file_path)    
    
    var file_vis: File = self._file_tree.get_file(file_path)
    menu.position = file_vis.get_viewport().get_screen_transform() \
                    * file_vis.get_global_transform_with_canvas() \
                    * Vector2.ZERO
    menu.popup(file_vis)


func toggle_dir_collapse(p: Path) -> void:
    if self._file_tree.is_dir_collapsed(p):
        self._file_tree.uncollapse_dir(p)
    else:
        self._file_tree.collapse_dir(p)


func delete_file_flow(path: Path) -> void:
    self._fs_man.remove_file(path)


func create_file_flow(path: Path) -> void:
    # Popup file creation menu
    var where: TreeNode = self._file_tree.get_file(path)
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
            self._fs_man.create_file(path.extend(msg))
            fname_popup.close_popup()
    )


func delete_dir_flow(path: Path) -> void:
    self._fs_man.remove_dir(path)


func create_dir_flow(path: Path) -> void:
    var where: TreeNode = self._file_tree.get_file(path)
    var dname_input := FCreateInput.make_new()
    var dname_popup := GPopup.make_into_popup(
        dname_input,
        where.get_viewport().get_screen_transform() \
            * where.get_global_transform_with_canvas() \
            * Vector2.ZERO
    )
    dname_input.setup("What do you want to name the directory?")
    
    dname_input.user_cancelled.connect(dname_popup.close_popup)
    dname_input.user_entered.connect(
        func (msg: String) -> void:
            self._fs_man.create_dir(path.extend(msg))
            dname_popup.close_popup()
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
    self._file_tree.highlight_path(Path.ROOT, Path.ROOT)
    self.completed.emit(
        preload("res://visualfs/narrator/lesson/completion.gd").new()
    )
    assert(
        self.get_reference_count() == 1,
        "Not all references to directory_07 removed before checkpoint exit."
    )
