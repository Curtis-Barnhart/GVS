extends RefCounted

var _name: String
var _contents: String


func _init(name: String, content: String="") -> void:
    self._name = name
    self._contents = content
