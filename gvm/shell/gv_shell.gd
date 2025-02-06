class_name GVShell
extends NinePatchRect

var PATH: Array[String]
var CWD: FSPath = FSPath.new([])
var fs_man: FSManager = null
const sh_prompt: String = "root@localhost$ "
static var scroll_frames: int = 1

@onready var history: Label = $ScrollContainer/VBoxContainer/History
@onready var prompt: TextEdit = $ScrollContainer/VBoxContainer/Prompt
@onready var scroll: ScrollContainer = $ScrollContainer


func setup(fs_manager: FSManager) -> void:
    self.fs_man = fs_manager


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
    self.history.text += "\n" \
                      + self.CWD.as_string() \
                      + " " \
                      + GVShell.sh_prompt \
                      + self.prompt.text
    
    # Array[String] I HATE TYPE ERASURE I HATE TYPE ERASURE I HATE TYPE ERA
    var input: Array = Array(self.prompt.text.split(" "))
    match input:
        ["cd", var where]:
            var loc: FSPath = self.CWD.compose(FSPath.new(where.split("/")))
            if self.fs_man.contains_dir(loc):
                self.CWD = self.fs_man.reduce_path(loc)
        ["mkdir", var name]:
            var loc: FSPath = self.CWD.compose(FSPath.new(name.split("/")))
            if fs_man.create_dir(loc):
                self.history.text += "\n%s created!" % fs_man.reduce_path(loc)
        ["ls"]:
            self.history.text += "\n" + "\n".join(self.fs_man.read_dirs_in_dir(self.CWD).map(func (path): return path.as_string()))
        ["clear"]:
            self.history.text = ""
        var huh:
            print("no match (%s)" % " ".join(input))
    
    self.prompt.clear()
    self.scroll_bottom()
