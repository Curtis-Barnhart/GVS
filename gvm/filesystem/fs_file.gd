extends RefCounted

const Directory = GVSClassLoader.gvm.filesystem.Directory
const Path = GVSClassLoader.gvm.filesystem.Path

var _name: String
# We don't use contents here but the file manager will
@warning_ignore("unused_private_class_variable")
var _contents: String
var _parent: Directory


func _init(name: String, parent: Directory) -> void:
    self._name = name
    self._parent = parent


func get_path() -> Path:
    return self._parent.get_path().extend(self._name)
