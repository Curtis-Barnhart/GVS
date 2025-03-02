extends Node2D

const PopupInput = GVSClassLoader.visualfs.narrator.PopupInput


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


func _draw() -> void:
    self.draw_rect(Rect2(0, 0, 738, 160), Color.RED, false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass


func _on_button_pressed() -> void:
    print("Button pressed!")


func _on_button_2_pressed() -> void:
    print("Popup made")
    var p: PopupInput = PopupInput.make_new()
    p.user_input.connect(func (msg: String) -> void: print("User message: " + msg))
    p.user_cancelled.connect(func () -> void: print("User cancelled popup"))
    p.popup(self)


func _on_button_3_pressed() -> void:
    print("Other button pressed")
