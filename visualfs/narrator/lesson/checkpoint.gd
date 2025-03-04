extends RefCounted

const FSManager = GVSClassLoader.gvm.filesystem.Manager
const Checkpoint = GVSClassLoader.visualfs.narrator.lesson.Checkpoint
const DragViewport = GVSClassLoader.visual.DragViewport.DragViewport

var _fs_man: FSManager
var _next_button: TextureButton
var _text_display: RichTextLabel
var _viewport: DragViewport

## The completed signal is how we tell the narrator we are done.
## We also have to pass back the next checkpoint to load.
## After this signal is sent, we will be freed from memory.
# Subclasses will use the signal
@warning_ignore("unused_signal")
signal completed(checkpoint: Checkpoint)


func _init(
    fs_manager: FSManager,
    next_button: TextureButton,
    text_label: RichTextLabel,
    viewport: DragViewport
) -> void:
    self._fs_man = fs_manager
    self._next_button = next_button
    self._text_display = text_label
    self._viewport = viewport


## Function to start a lesson.
func start() -> void:
    assert(false, "Checkpoint is an ABC that shouldn't have been instantiated.")
    return
