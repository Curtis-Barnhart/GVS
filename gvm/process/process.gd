class_name GVProcess
extends RefCounted

const ClassLoader = preload("res://gvs_class_loader.gd")
const FSManager = ClassLoader.gvm.filesystem.Manager
const Path = ClassLoader.gvm.filesystem.Path
const IOQueue = ClassLoader.gvm.util.IOQueue

var fs_man: FSManager = null
## Queue to read strings from
var stdin: IOQueue
## Queue of output strings
var stdout: IOQueue
var vargs: PackedStringArray
var cwd: Path


func _init(
    filesystem_manager: FSManager,
    standard_in: IOQueue,
    standard_out: IOQueue,
    arguments: PackedStringArray,
    cur_work_dir: Path
) -> void:
    self.fs_man = filesystem_manager
    self.stdin = standard_in
    self.stdout = standard_out
    self.vargs = arguments
    self.cwd = cur_work_dir


func run() -> int:
    # An abstract process can't run!
    assert(false)
    return 0
