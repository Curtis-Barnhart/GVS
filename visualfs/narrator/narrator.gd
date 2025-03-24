extends Control

const Checkpoint = GVSClassLoader.visualfs.narrator.lesson.Checkpoint
const FSManager = GVSClassLoader.gvm.filesystem.Manager
const DragViewport = GVSClassLoader.visual.DragViewport.DragViewport
const Narrator = GVSClassLoader.visualfs.narrator.Narrator

var _fs_man: FSManager
var _viewport: DragViewport
var _cur_checkpt: Checkpoint
@onready var _line_edit: LineEdit = $VBoxContainer/LineEdit
@onready var _next_button: Button = $VBoxContainer/Button
@onready var _text: RichTextLabel = $VBoxContainer/RichTextLabel


func setup(
    fs_manager: FSManager,
    viewport: DragViewport
) -> void:
    self._fs_man = fs_manager
    self._viewport = viewport
    self.load_checkpoint(
        preload("res://visualfs/narrator/lesson/directories/directory_00.gd").new(),
        true
    )


func load_checkpoint(c: Checkpoint, needs_context: bool = false) -> void:
    # have to hold a reference so it's not deleted from memory while it waits lol
    self._cur_checkpt = c
    self._next_button.disabled = false
    c.setup(
        self._fs_man,
        self._next_button,
        self._text,
        self._viewport,
        self._line_edit
    )
    c.start(needs_context)
    c.completed.connect(self.load_checkpoint)
