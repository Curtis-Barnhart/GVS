extends "res://visualfs/narrator/lesson/checkpoint.gd"

#const FSManager = GVSClassLoader.gvm.filesystem.Manager
#const Checkpoint = GVSClassLoader.visualfs.narrator.lesson.Checkpoint
const UtilString = GVSClassLoader.shared.Strings

#var _fs_man: FSManager
#var _next_button: Button


func start() -> void:
    self._text_display.text = UtilString.make_article(["Title", ["Here is some text"]])
