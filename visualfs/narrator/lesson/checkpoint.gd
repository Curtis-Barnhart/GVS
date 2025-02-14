extends RefCounted

const FSManager = GVSClassLoader.gvm.filesystem.Manager

var _fs_man: FSManager


func _init(
    fs_manager: FSManager
) -> void:
    self._fs_man = fs_manager
