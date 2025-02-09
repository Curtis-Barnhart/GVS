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
