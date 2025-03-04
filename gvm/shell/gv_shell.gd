## GVShell is a class that acts as a sort of shell.
## It allows someone interacting with it to manipulate a backing
## filesystem (the GVShell contains a FSManager instance).
extends NinePatchRect

const ClassLoader = preload("res://gvs_class_loader.gd")
const FSManager = ClassLoader.gvm.filesystem.Manager
const Path = ClassLoader.gvm.filesystem.Path
const Mkdir = ClassLoader.gvm.process.premade.Mkdir
const Rmdir = ClassLoader.gvm.process.premade.Rmdir
const Ls = ClassLoader.gvm.process.premade.Ls
const Shell = ClassLoader.gvm.Shell
const IOQueue = ClassLoader.gvm.util.IOQueue
const StringsUtil = ClassLoader.shared.Strings

signal cwd_changed(path: Path, old_path: Path)
signal previewing_path(origin: Path, path: Path)

## Stores the current working directory of the shell.
## Aside from after the GVShell is initialized but before setup() is called,
## this must always be a valid path to a directory in the backing filesystem.
var CWD: Path = Path.ROOT
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
## Contains the last highlighted path so that we don't have to send repeat signals
## every time the prompt caret is over a valid path.
## I'm fairly certain rehighlighting the path is somewhat expensive
var last_preview_origin: Path = Path.ROOT
var last_preview_path: Path = Path.ROOT

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
    var shell: Shell

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
            var old_cwd: Path = self.CWD
            self.CWD = Path.ROOT
            self.cwd_changed.emit(self.CWD, old_cwd)
        ["cd", var where]:
            var old_cwd: Path = self.CWD
            var loc: Path = self.CWD.as_cwd(where as String)
            if self.fs_man.contains_dir(loc):
                self.CWD = self.fs_man.reduce_path(loc)
                self.cwd_changed.emit(self.CWD, old_cwd)
            elif self.fs_man.contains_file(loc):
                self.history.text += "-gvs: cd: %s: Not a directory\n" % where
            else:
                self.history.text += "-gvs: cd: %s: No such file or directory\n" % where
        ["cd", ..]:
            self.history.text += "-gvs: cd: too many arguments\n"
        ["mkdir", ..]:
            var mkdir_proc: Mkdir = Mkdir.new(
                self.fs_man,
                null,
                self.shell_write,
                input,
                self.CWD
            )
            mkdir_proc.run()
        ["rmdir", ..]:
            var rmdir_proc: Rmdir = Rmdir.new(
                self.fs_man,
                null,
                self.shell_write,
                input,
                self.CWD
            )
            rmdir_proc.run()
        ["ls", ..]:
            var ls_proc: Ls = Ls.new(
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


## Sets scroll_frames to 1 so that we scroll down again.
## Should be connected to the prompt text changing.
func _on_prompt_text_changed() -> void:
    self.scroll_frames = 1


## Checks if the user is currently typing a valid pathname.
## If so, broadcasts it.
func _on_prompt_caret_changed() -> void:
    # get_word_under_caret works if the caret is in the middle of or at the
    # start of a word, but does not work if we're at the end of one,
    # which is unfortunately where you are while you type.
    var caret_string: String = self.prompt.get_word_under_caret()
    if caret_string == "":
        # Get most recent previous non space character
        var last_char: int = StringsUtil.prev_f(
            self.prompt.text,
            self.prompt.get_caret_column() - 1,
            func (c: String) -> bool: return c != " "
        )
        
        # If there is no word to analyze at all (no previous non space character),
        # we check if we've already broadcasted this recently, and if we haven't,
        # we broadcast an empty highlight.
        if last_char == -1:
            if (
                self.last_preview_origin.degen()
                and self.last_preview_path.degen()
            ):
                return
            else:
                self.last_preview_origin = Path.ROOT
                self.last_preview_path = Path.ROOT
                self.previewing_path.emit(Path.ROOT, Path.ROOT)
                return
        
        # Get the word behind the cursor (no matter how much whitespace)
        caret_string = StringsUtil.extract_word(self.prompt.text, last_char)
    
    # Try to interpret the path the user is typing and its parent.
    # If the user is typing a path, when they start a new name,
    # it will be incorrect since they are still typing.
    # However, the parent will be correct, which we can still detect.
    var caret_path: Path = Path.new(caret_string.split("/", false))
    var parent_path: Path = caret_path.base()

    if caret_string.begins_with("/"):
        # Absolute path detected
        if self.fs_man.contains_dir(caret_path):
            # whole path was found - check if we've already broadcasted,
            # if not, then broadcast it
            if not (
                self.last_preview_origin.degen()
                and self.last_preview_path.as_string() == caret_path.as_string()
            ):
                self.last_preview_origin = Path.ROOT
                self.last_preview_path = caret_path
                self.previewing_path.emit(Path.ROOT, caret_path)
            return
        elif self.fs_man.contains_dir(parent_path):
            # whole path was not found, but it looks like a partially written out
            # path because we could find its parent - check if we've already
            # broadcasted, if not, then broadcast it
            if not (
                self.last_preview_origin.degen()
                and self.last_preview_path.as_string() == parent_path.as_string()
            ):
                self.last_preview_origin = Path.ROOT
                self.last_preview_path = parent_path
                self.previewing_path.emit(Path.ROOT, parent_path)
            return
        # path could not be located as absolute path
    else:
        # Relative path detected
        if self.fs_man.contains_dir(self.CWD.compose(caret_path)):
            # whole path was found - check if we've already broadcasted,
            # if not, then broadcast it
            if not (
                self.last_preview_origin.as_string() == self.CWD.as_string()
                and self.last_preview_path.as_string() == caret_path.as_string()
            ):
                self.last_preview_origin = self.CWD
                self.last_preview_path = caret_path
                self.previewing_path.emit(self.CWD, caret_path)
            return
        elif self.fs_man.contains_dir(self.CWD.compose(parent_path)):
            # whole path was not found, but it looks like a partially written out
            # path because we could find its parent - check if we've already
            # broadcasted, if not, then broadcast it
            if not (
                self.last_preview_origin.as_string() == self.CWD.as_string()
                and self.last_preview_path.as_string() == parent_path.as_string()
            ):
                self.last_preview_origin = self.CWD
                self.last_preview_path = parent_path
                self.previewing_path.emit(self.CWD, parent_path)
            return
        # path could not be found as a relative path    
    
    # If we recently broadcasted a legitimate path, let's broadcast again
    # to signal that we no longer have a path from the user
    if not (
        self.last_preview_origin.degen()
        and self.last_preview_path.degen()
    ):
        self.last_preview_origin = Path.ROOT
        self.last_preview_path = Path.ROOT
        self.previewing_path.emit(Path.ROOT, Path.ROOT)
