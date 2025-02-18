extends RefCounted

const FSManager = GVSClassLoader.gvm.filesystem.Manager
const Checkpoint = GVSClassLoader.visualfs.narrator.lesson.Checkpoint
const DragViewport = GVSClassLoader.visual.DragViewport.DragViewport

var _fs_man: FSManager
var _next_button: Button
var _viewport: DragViewport

## The completed signal is how we tell the narrator we are done.
## We also have to pass back the next checkpoint to load.
## After this signal is sent, we will be freed from memory.
signal completed(checkpoint: Checkpoint)


func _init(
    fs_manager: FSManager,
    next_button: Button,
    viewport: DragViewport
) -> void:
    self._fs_man = fs_manager
    self._next_button = next_button
    self._viewport = viewport


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
