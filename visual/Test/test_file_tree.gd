extends Control

const FManager = GVSClassLoader.gvm.filesystem.Manager
const Path = GVSClassLoader.gvm.filesystem.Path
const FileTree = GVSClassLoader.visual.FileTree
const File = GVSClassLoader.visual.file_nodes.BaseNode
const Dir = GVSClassLoader.visual.file_nodes.TreeNode
const Menu = GVSClassLoader.visual.buttons.CircleMenu
const DragViewport = GVSClassLoader.visual.DragViewport.DragViewport
const TreeNode = GVSClassLoader.visual.file_nodes.TreeNode
const GPopup = GVSClassLoader.visual.GVSPopup
const FileReader = GVSClassLoader.visual.FileReader
const FileWriter = GVSClassLoader.visual.FileWriter
const FCreateInput = GVSClassLoader.visual.SimpleInput

var ft: FileTree
var fs_man: FManager


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    self.fs_man = FManager.new()
    self.ft = FileTree.make_new()
    fs_man.created_dir.connect(ft.create_node_dir)
    fs_man.removed_dir.connect(ft.remove_node)
    fs_man.created_file.connect(ft.create_node_file)
    fs_man.removed_file.connect(ft.remove_node)
    ($DragViewport as DragViewport).add_to_scene(ft)
    
    self.ft.file_clicked.connect(self.menu_popup)


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
    
    menu.menu_closed.connect(
        func (x: int) -> void:
            match x:
                0:
                    self.create_dir_flow(file_path)
                1:
                    self.delete_dir_flow(file_path)
                2:
                    self.create_file_flow(file_path)
    )


func menu_popup(file_path: Path) -> void:
    var menu: Menu = Menu.make_new()

    match self.fs_man.contains_type(file_path):
        FManager.filetype.DIR:
            self.menu_settings_dir(menu, file_path)
        FManager.filetype.FILE:
            self.menu_settings_file(menu, file_path)    
    
    var file_vis: File = self.ft.get_file(file_path)
    menu.position = file_vis.get_viewport().get_screen_transform() \
                    * file_vis.get_global_transform_with_canvas() \
                    * Vector2.ZERO
    menu.popup(file_vis)


func delete_file_flow(path: Path) -> void:
    self.fs_man.remove_file(path)


func create_file_flow(path: Path) -> void:
    # Popup file creation menu
    var where: TreeNode = self.ft.get_file(path)
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
            self.fs_man.create_file(path.extend(msg))
            fname_popup.close_popup()
    )


func delete_dir_flow(path: Path) -> void:
    self.fs_man.remove_dir(path)


func create_dir_flow(path: Path) -> void:
    var where: TreeNode = self.ft.get_file(path)
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
            self.fs_man.create_dir(path.extend(msg))
            dname_popup.close_popup()
    )


func file_read_popup(path: Path) -> void:
    var file_vis: File = self.ft.get_file(path)
    var reader := FileReader.make_new()
    var popup := GPopup.make_into_popup(reader)
    popup.position = file_vis.get_viewport().get_screen_transform() \
                    * file_vis.get_global_transform_with_canvas() \
                    * Vector2.ZERO
    reader.load_text(self.fs_man.read_file(path))


func file_write_popup(path: Path) -> void:
    var file_vis: File = self.ft.get_file(path)
    var writer := FileWriter.make_new()
    var popup := GPopup.make_into_popup(writer)
    popup.position = file_vis.get_viewport().get_screen_transform() \
                    * file_vis.get_global_transform_with_canvas() \
                    * Vector2.ZERO
    writer.load_text(self.fs_man.read_file(path))
    
    writer.write.connect(
        func (text: String) -> void:
            var written: bool = self.fs_man.write_file(path, text)
            assert(written)
    )
    writer.quit.connect(popup.close_popup)
