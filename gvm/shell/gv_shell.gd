class_name GVShell
extends NinePatchRect

var PATH: Array[String]
var CWD: String = ""
const sh_prompt: String = "root@localhost$ "
static var scroll_frames: int = 2

@onready var history: Label = $ScrollContainer/VBoxContainer/History
@onready var prompt: TextEdit = $ScrollContainer/VBoxContainer/Prompt
@onready var scroll: ScrollContainer = $ScrollContainer


# We do this because on resize of the prompt, we scroll,
# but the actual resizing occurs after, so we need a way to scroll for 2 frames
func scroll_bottom() -> void:
    self.scroll_frames = 2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    self.scroll_bottom()
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if self.scroll_frames > 0:
        self.scroll.scroll_vertical = 999999
        self.scroll_frames -= 1


func _on_prompt_user_entered() -> void:
    self.history.text += "\n" + GVShell.sh_prompt + self.prompt.text
    self.prompt.clear()
    self.scroll_bottom()
