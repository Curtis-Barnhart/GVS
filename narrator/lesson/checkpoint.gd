extends RefCounted

const FSManager = GVSClassLoader.gvm.filesystem.Manager
const Shell = GVSClassLoader.gvm.Shell
const Checkpoint = GVSClassLoader.narrator.lesson.Checkpoint

var fs_man: FSManager
var text_screen: RichTextLabel
var shell: Shell
var next_button: Button

## The completed signal is how we tell the narrator we are done.
## We also have to pass back the next checkpoint to load.
## After this signal is sent, we will be freed from memory.
# Subclasses will use this signal
@warning_ignore("unused_signal")
signal completed(checkpoint: Checkpoint)


func _init(
    fs_man: FSManager,
    text_screen: RichTextLabel,
    shell: Shell,
    next_button: Button
) -> void:
    self.fs_man = fs_man
    self.text_screen = text_screen
    self.shell = shell
    self.next_button = next_button


## Function to start a lesson.
func start() -> void:
    assert(false, "Checkpoint is an ABC that shouldn't have been instantiated.")
    return


## Helper function to format text with BBCode markup.
## first element of text should be the title (String).
## every subsequent element should be an array of strings,
## where each array is one paragraph in full.
## the elements of each array will be joined with spaces,
## and the arrays themselves with two newlines and 4 spaces for indentation.
##
## @param text: data structure with strings to format.
## @return: formatted string with BBCode markup.
static func make_article(text: Array) -> String:
    return "[font=res://shared/JetBrainsMonoNerdFontMono-Regular.ttf][font_size=48][center][color=steel blue]%s[/color][/center][/font_size][font_size=36]\n\n    " % text[0] + \
        "\n\n    ".join(
            text.slice(1) \
                .map(func (sent: Array) -> String: return " ".join(sent))
        ) + \
        "[/font_size][/font]"
