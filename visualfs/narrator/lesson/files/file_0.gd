extends "res://visualfs/narrator/lesson/checkpoint.gd"

const UtilString = GVSClassLoader.shared.Strings
const FileList = GVSClassLoader.visualfs.FileList
const Path = GVSClassLoader.gvm.filesystem.Path
const File = GVSClassLoader.visual.file_nodes.File
const Menu = GVSClassLoader.visual.buttons.CircleMenu

var _first_file := Path.new(["This is a file"])
var _file_list: FileList


func start() -> void:
    # Create a new file list (and manager) and add it to the drag viewport
    # so that we can retrieve it and its children later.
    self._file_list = FileList.make_new()
    self._viewport.add_to_scene(self._file_list)
    self._file_list.name = "FileList"
    
    # Connect file list to manager and add a file
    var fname := self._first_file
    self._fs_man.created_file.connect(self._file_list.add_file)
    self._fs_man.removed_file.connect(self._file_list.remove_file)
    self._fs_man.create_file(fname)
    var file_vis: File = self._file_list.get_file(self._first_file)
    assert(file_vis != null, "Could not find file in FileList that we just made.")
    
    # Make sure continue button is disabled at start and only enables
    # after the user has read the file
    self._next_button.disabled = true
    self._next_button.pressed.connect(self.finish)
    file_vis.connect_to_press(self.menu_popup)
    
    self._text_display.text = UtilString.make_article(
        [
            "What is a File?",
            [
                "How does your computer remember anything?",
                "How does it know what images you have,",
                "or what music you listened to last?",
                "How does it know what tabs you had opened in your web browser?",
            ],
            [
                "The answer to all of these questions is [color=steel blue]files[/color].",
                "Files are storage containers where your computer puts anything",
                "it needs to remember for a long amount of time.",
            ]
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
                    print("Selected 0")
                1:
                    print("Selected 1")
    )


func finish() -> void:
    #self._file_list.get_file(self._first_file).disconnect_from_press(self.menu_popup)
    self.completed.emit(load("res://visualfs/narrator/lesson/completion.gd").new(
        self._fs_man, self._next_button, self._text_display, self._viewport
    ))
