class_name Checkpoint
extends RefCounted


var fs_man: FSManager
signal completed


func _init(filesystem_manager: FSManager) -> void:
    assert(filesystem_manager != null)
    self.fs_man = filesystem_manager


func check_completion() -> bool:
    # Checkpoint is an ABC that can't be instantiated
    assert(false, "Checkpoint is an ABC that shouldn't have been instantiated.")
    return false
