## GVShell is a class that acts as a sort of shell.
## It allows someone interacting with it to manipulate a backing
## filesystem (the GVShell contains a FSManager instance).

class_name GVShell
extends NinePatchRect

signal cwd_changed(path: FSPath, old_path: FSPath)
signal previewing_path(origin: FSPath, path: FSPath)

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
    ## @param message: message to write to the history Label.
    func write(message: String) -> void:
        self.shell.history.text += message
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
func _process(_delta: float) -> void:
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
            var old_cwd: FSPath = self.CWD
            self.CWD = FSPath.new([])
            self.cwd_changed.emit(self.CWD, old_cwd)
        ["cd", var where]:
            var old_cwd: FSPath = self.CWD
            var loc: FSPath = self.CWD.compose(FSPath.new(where.split("/")))
            if self.fs_man.contains_dir(loc):
                self.CWD = self.fs_man.reduce_path(loc)
                self.cwd_changed.emit(self.CWD, old_cwd)
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
        ["pwd", ..]:
            self.history.text += self.CWD.as_string() + "\n"
        _:
            self.history.text += "gvs: %s: command not found...\n" % " ".join(input)

    self.prompt.clear()
    self.history.text += self.CWD.as_string() + " $ "
    self.scroll_frames = 1


func _on_prompt_text_changed() -> void:
    self.scroll_frames = 1


func _on_prompt_caret_changed() -> void:
    var caret_string: String = self.prompt.get_word_under_caret()
    if caret_string == "":
        var last_char: int = utils_strings.prev_f(
            self.prompt.text,
            self.prompt.get_caret_column() - 1,
            func (c): return c != " "
        )
        if last_char == -1:
            # There is no word to analyze at all
            return      
        caret_string = utils_strings.extract_word(self.prompt.text, last_char)
    
    var caret_path: FSPath = FSPath.new(caret_string.split("/", false))
    var parent_path: FSPath = caret_path.base()
    print("\nWord '%s' detected - path '%s'" % [caret_string, caret_path.as_string()])
    if caret_string.begins_with("/"):
        print("Absolute path detected")
        print("Paths changed to:\n\t%s\n\t%s" % [caret_path.as_string(), parent_path.as_string()])
        if self.fs_man.contains_dir(caret_path):
            print("path found")
            self.previewing_path.emit(FSPath.ROOT, caret_path)
        elif self.fs_man.contains_dir(parent_path):
            print("partial path found")
            self.previewing_path.emit(FSPath.ROOT, parent_path)
        else:
            print("Path %s not located" % caret_path.as_string())
        

    #if self.fs_man.contains_dir(caret_path):
        #self.previewing_path.emit()
