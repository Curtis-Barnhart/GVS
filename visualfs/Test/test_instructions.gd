extends Control

const Instructions = GVSClassLoader.visualfs.narrator.Instructions
const Command = Instructions.Command

@onready var _ins: Instructions = $Instructions


func _ready() -> void:
    self._ins.add_command(Command.new("Huhh??"))
    self._ins.get_command(0).add_command(Command.new("yeahhhhhhh"))
    self._ins.get_command(0).get_command(0).set_fulfill(true)
    self._ins.add_command(Command.new("another"))
    self._ins.render()
