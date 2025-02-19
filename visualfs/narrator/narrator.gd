extends Control

const Checkpoint = GVSClassLoader.visualfs.narrator.lesson.Checkpoint
const FSManager = GVSClassLoader.gvm.filesystem.Manager
const PopupInput = GVSClassLoader.visualfs.narrator.PopupInput
const DragViewport = GVSClassLoader.visual.DragViewport.DragViewport

var _fs_man: FSManager
var _viewport: DragViewport
var _cur_checkpt: Checkpoint
@onready var _next_button: TextureButton = $VBoxContainer/TextureButton
@onready var _text: RichTextLabel = $VBoxContainer/RichTextLabel

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:


func user_dialog(text_callback: Callable, cancel_callback: Callable) -> void:
    var popup: PopupInput = PopupInput.make_new()
    popup.user_input.connect(text_callback)
    popup.user_cancelled.connect(cancel_callback)
    popup.popup(self)


func setup(
    fs_manager: FSManager,
    viewport: DragViewport
):
    self._fs_man = fs_manager
    self._viewport = viewport
    var first_checkpoint: Checkpoint = load("res://visualfs/narrator/lesson/files/file_0.gd").new(
        self._fs_man, self._next_button, self._text
    )
    first_checkpoint.start()
    #self.load_checkpoint(
        #load("res://visualfs/narrator/lesson/files/file_0.gd").new(
            #self._fs_man, self._next_button, self._text
        #)
    #)



func load_checkpoint(c: Checkpoint) -> void:
    # have to hold a reference so it's not deleted from memory while it waits lol
    self._cur_checkpt = c
    self._next_button.disabled = true
    c.start()
    c.completed.connect(self.load_checkpoint)
