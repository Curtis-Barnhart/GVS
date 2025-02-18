extends RefCounted

const Directory = GVSClassLoader.gvm.filesystem.Directory
const Path = GVSClassLoader.gvm.filesystem.Path

var _name: String
var _contents: String
var _parent: Directory


func _init(name: String, parent: Directory) -> void:
    self._name = name
    self._parent = parent


func get_path() -> Path:
    return self._parent.get_path().extend(self._name)
