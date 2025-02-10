class_name Checkpoint
extends RefCounted

var fs_man: FSManager
var text_screen: RichTextLabel
var shell: GVShell
var next_button: Button

signal completed(checkpoint: Checkpoint)


func _init(
    fs_man: FSManager,
    text_screen: RichTextLabel,
    shell: GVShell,
    next_button: Button
) -> void:
    self.fs_man = fs_man
    self.text_screen = text_screen
    self.shell = shell
    self.next_button = next_button


func start() -> void:
    assert(false, "Checkpoint is an ABC that shouldn't have been instantiated.")
    return


static func make_article(text) -> String:
    return "[font=res://shared/JetBrainsMonoNerdFontMono-Regular.ttf][font_size=48][center][color=steel blue]%s[/color][/center][/font_size][font_size=36]\n\n    " % text[0] + \
        "\n\n    ".join(text.slice(1).map(func (sent): return " ".join(sent))) + \
        "[/font_size][/font]"
