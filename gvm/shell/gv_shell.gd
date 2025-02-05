class_name GVShell
extends ScrollContainer

var PATH: Array[String]
var CWD: String = ""
const sh_prompt: String = "root@localhost"
var scroll_frames: int = 2

@onready var history: Label = $VBoxContainer/History
@onready var prompt: TextEdit = $VBoxContainer/Prompt


func scroll_bottom() -> void:
    self.scroll_frames = 2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    self.scroll_bottom()
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if self.scroll_frames > 0:
        self.scroll_vertical = 999999
        self.scroll_frames -= 1


func _on_prompt_user_entered() -> void:
    self.history.text += "\n" + self.prompt.text
    self.prompt.clear()
    self.scroll_bottom()
