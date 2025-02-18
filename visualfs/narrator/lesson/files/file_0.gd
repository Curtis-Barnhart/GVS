extends "res://visualfs/narrator/lesson/checkpoint.gd"

#const FSManager = GVSClassLoader.gvm.filesystem.Manager
#const Checkpoint = GVSClassLoader.visualfs.narrator.lesson.Checkpoint

#var _fs_man: FSManager
#var _next_button: Button


func start() -> void:
    pass


func load_checkpoint(c: Checkpoint) -> void:
    # have to hold a reference so it's not deleted from memory while it waits lol
    self.current_checkpoint = c
    self.next.disabled = true
    c.start()
    c.completed.connect(self.load_checkpoint)
