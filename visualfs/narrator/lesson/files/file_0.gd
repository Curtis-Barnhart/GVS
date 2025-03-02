extends "res://visualfs/narrator/lesson/checkpoint.gd"

const UtilString = GVSClassLoader.shared.Strings
const FileList = GVSClassLoader.visualfs.FileList
const Path = GVSClassLoader.gvm.filesystem.Path


func start() -> void:
    var file_list := FileList.make_new()
    self._viewport.add_to_scene(file_list)
    file_list.name = "FileList"
    
    var fname := Path.new(["This is a file"])
    self._fs_man.created_file.connect(file_list.add_file)
    self._fs_man.removed_file.connect(file_list.remove_file)
    self._fs_man.create_file(fname)
    
    self._next_button.disabled = true
    (self._viewport.node_from_scene("FileList") as FileList) \
        .get_file(fname) \
        .connect_to_press(func () -> void: self._next_button.disabled = false)
    
    self._next_button.pressed.connect(func () -> void: print("Button pressed!"))
    
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
    print(self._text_display)
