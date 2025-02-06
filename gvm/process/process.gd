class_name GVProcess
extends RefCounted

var fs_man: FSManager = null
## Queue to read strings from
var stdin: IOQueue
## Queue of output strings
var stdout: IOQueue
var vargs: PackedStringArray
var cwd: FSPath


func _init(
    fs_manager: FSManager,
    stdin: IOQueue,
    stdout: IOQueue,
    vargs: PackedStringArray,
    cwd: FSPath
) -> void:
    self.fs_man = fs_manager
    self.stdin = stdin
    self.stdout = stdout
    self.vargs = vargs
    self.cwd = cwd


func run() -> int:
    # An abstract process can't run!
    assert(false)
    return 0
