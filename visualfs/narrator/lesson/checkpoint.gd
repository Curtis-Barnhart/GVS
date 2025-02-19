extends RefCounted

const FSManager = GVSClassLoader.gvm.filesystem.Manager
const Checkpoint = GVSClassLoader.visualfs.narrator.lesson.Checkpoint

var _fs_man: FSManager
var _next_button: TextureButton
var _text_display: RichTextLabel

## The completed signal is how we tell the narrator we are done.
## We also have to pass back the next checkpoint to load.
## After this signal is sent, we will be freed from memory.
signal completed(checkpoint: Checkpoint)


func _init(
    fs_manager: FSManager,
    next_button: TextureButton,
    text_label: RichTextLabel
) -> void:
    self._fs_man = fs_manager
    self._next_button = next_button
    self._text_display = text_label


## Function to start a lesson.
func start() -> void:
    assert(false, "Checkpoint is an ABC that shouldn't have been instantiated.")
    return


func load_checkpoint(c: Checkpoint) -> void:
    # have to hold a reference so it's not deleted from memory while it waits lol
    self.current_checkpoint = c
    self.next.disabled = true
    c.start()
    c.completed.connect(self.load_checkpoint)
