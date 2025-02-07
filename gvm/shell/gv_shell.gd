## GVShell is a class that acts as a sort of shell.
## It allows someone interacting with it to manipulate a backing
## filesystem (the GVShell contains a FSManager instance).

class_name GVShell
extends NinePatchRect

## Stores the current working directory of the shell.
## Aside from after the GVShell is initialized but before setup() is called,
## this must always be a valid path to a directory in the backing filesystem.
var CWD: FSPath = FSPath.new([])
## The filesystem that this GVShell is attached to.
var fs_man: FSManager = null
## This the GVShell's "fake" IOQueue - it can give it to a process as the
## process' stdout, but instead of collecting text,
## it will immediately print to the GVShell's display
var shell_write: ShellWriter = ShellWriter.new()
## Due to the ordering of signals and events, we need to have a way to queue up
## a scrolling down motion a frame in the future.
## When scroll_frames > 0, the _process function knows to scroll down
## and decrement scroll_frames.
var scroll_frames: int = 1

## history is a label that displays the past history of all commands
## and command outputs.
@onready var history: Label = $ScrollContainer/VBoxContainer/History
## prompt is the prompt to the user to enter text.
@onready var prompt: TextEdit = $ScrollContainer/VBoxContainer/Prompt
## scroll is the scroll container that contains all visual elements
## (the history and prompt).
## We only need a reference to this so we can scroll down automatically
## after any user input or text output occurs.
@onready var scroll: ScrollContainer = $ScrollContainer


## ShellWriter is a special IOQueue that prints out any received text
## to the history Label of the GVShell.
## Because there should only ever exist one, we don't worry about a c'tor.
class ShellWriter extends IOQueue:
    ## GVShell who owns this ShellWriter so we can set their scroll_frames
    ## after printing to their screen.
    var shell: GVShell

    ## Overrides IOQueue's write method to write immediately to history Label.
    ##
    ## @param str: message to write to the history Label.
    func write(str: String) -> void:
        self.shell.history.text += str
        self.shell.scroll_frames = 1


## GVShell needs to be given an FSManager so that it can interact with
## a filesystem (that it does not own).
## We throw this into a setup function in case there is anything else
## that we will want to initialize in the future.
##
## @param fs_manager: the file system to attach to this GVShell.
func setup(fs_manager: FSManager) -> void:
    self.fs_man = fs_manager
    # Set initial history text to show first prompt so it's not empty
    self.history.text = "/ $ "


## On entering the scene, we set give GVShell's history Label to
## the sole ShellWriter instance so that it knows where to write.
func _ready() -> void:
    self.shell_write.shell = self


## Every frame we scroll down if scroll_frames has been set.
##
## @param delta: elapsed time since the previous frame.
func _process(delta: float) -> void:
    if self.scroll_frames > 0:
        self.scroll.scroll_vertical = 999999
        self.scroll_frames -= 1


## This is called when the prompt detects that the user has hit enter
## while typing into it.
## We now have a chance to process what the user has written,
## which at the moment is done in a huge pattern matching statement.
## At some point this will probably have to be more sophisticated?
func _on_prompt_user_entered() -> void:
    self.history.text += self.prompt.text + "\n"

    var input: PackedStringArray = self.prompt.text.split(" ", false)
    match Array(input):
        # A process cannot be made for cd because it would have to
        # be able to access the GVShell's CWD, which... on second thought,
        # is actually totally reasonable and could be done eventually.
        ["cd"]:
            self.CWD = FSPath.new([])
        ["cd", var where]:
            var loc: FSPath = self.CWD.compose(FSPath.new(where.split("/")))
            if self.fs_man.contains_dir(loc):
                self.CWD = self.fs_man.reduce_path(loc)
            elif self.fs_man.contains_file(loc):
                self.history.text += "-gvs: cd: %s: Not a directory\n"
            else:
                self.history.text += "-gvs: cd: %s: No such file or directory\n"
        ["cd", ..]:
            self.history.text += "-gvs: cd: too many arguments\n"
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
        # remove history on single command "clear"
        ["clear"]:
            self.history.text = ""
        ["clear", ..]:
            self.history.text += "Usage: clear\n"
        ["exit", ..]:
            self.get_tree().quit(0)
        var huh:
            self.history.text += "gvs: %s: command not found...\n" % " ".join(input)

    self.prompt.clear()
    self.history.text += self.CWD.as_string() + " $ "
    self.scroll_frames = 1
