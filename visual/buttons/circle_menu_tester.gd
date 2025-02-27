extends Node2D


const CMenu = preload("res://visual/buttons/CircleMenu.tscn")
var cmenu: Node2D = null
@onready var _button = $TextureButton


func _on_texture_button_pressed() -> void:
    print("menu clicked")
    self.cmenu = CMenu.instantiate()
    
    var s: Sprite2D = Sprite2D.new()
    s.texture = load("res://visual/assets/directory.svg")
    self.cmenu.add_child(s)
    s = Sprite2D.new()
    s.texture = load("res://visual/assets/directory.svg")
    self.cmenu.add_child(s)
    self.cmenu.position = self._button.position + self._button.size / 2
    s = Sprite2D.new()
    s.texture = load("res://visual/assets/directory.svg")
    self.cmenu.add_child(s)
    
    self.cmenu.popup(self)
    self._button.disabled = true
    self.cmenu.menu_closed.connect(func (_x): self._button.disabled = false)
    self.cmenu.menu_closed.connect(func (selection): print("Selected ", selection))
