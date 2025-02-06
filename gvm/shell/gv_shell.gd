class_name GVShell
extends NinePatchRect

var PATH: Array[String]
var CWD: FSPath = FSPath.new([])
var fs_man: FSManager = null
var shell_write: ShellWriter = ShellWriter.new()
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
    self.shell_write.history = self.history
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if self.scroll_frames > 0:
        self.scroll.scroll_vertical = 999999
        self.scroll_frames -= 1


func write(msg: String) -> void:
    self.history.text += msg + "\n"


class ShellWriter extends IOQueue:
    var history: Label
    
    func write(str: String) -> void:
        self.history.text += str


func _on_prompt_user_entered() -> void:
    self.history.text += self.CWD.as_string() \
                      + " " \
                      + GVShell.sh_prompt \
                      + self.prompt.text \
                      + "\n"
    
    # Array[String] I HATE TYPE ERASURE I HATE TYPE ERASURE I HATE TYPE ERA
    var input: PackedStringArray = self.prompt.text.split(" ", false)
    match Array(input):
        ["cd", var where]:
            var loc: FSPath = self.CWD.compose(FSPath.new(where.split("/")))
            if self.fs_man.contains_dir(loc):
                self.CWD = self.fs_man.reduce_path(loc)
        ["mkdir", ..]:
            var mkdir_proc: ProcessMkdir = ProcessMkdir.new(
                self.fs_man,
                null,
                self.shell_write,
                input,
                self.CWD
            )
            mkdir_proc.run()
        ["rmdir", ..]:
            var rmdir_proc: ProcessRmdir = ProcessRmdir.new(
                self.fs_man,
                null,
                self.shell_write,
                input,
                self.CWD
            )
            rmdir_proc.run()
        ["ls", ..]:
            var ls_proc: ProcessLs = ProcessLs.new(
                self.fs_man,
                null,
                self.shell_write,
                input,
                self.CWD
            )
            ls_proc.run()
        ["clear"]:
            self.history.text = ""
        var huh:
            print("no match (%s)" % " ".join(input))
    
    self.prompt.clear()
    self.scroll_bottom()
