extends Control

const GVSPopup = GVSClassLoader.visual.popups.GVSPopup
const FileReader = GVSClassLoader.visual.FileReader

#@onready var _button: TextureButton = $TextureButton


func _on_texture_button_pressed() -> void:
    var fr := FileReader.make_new()
    GVSPopup.make_into_popup(fr, self, Vector2(800, 600))
    fr.load_text("Hello! How are you doing?")
