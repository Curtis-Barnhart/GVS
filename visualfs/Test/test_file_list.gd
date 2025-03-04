extends Node2D

const FileList = GVSClassLoader.visualfs.FileList
const File = GVSClassLoader.visual.file_nodes.File
const Path = GVSClassLoader.gvm.filesystem.Path


@onready var f_list: FileList = $FileList

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    while true:
        var t: float = 0.25
        for x in range(64):
            self.f_list.add_file(Path.new([str(x)]))
            await get_tree().create_timer(t).timeout
            t = max(0.95*t, 1.0/16)
        
        t = 2
        var nums: Array = range(64)
        for _a in range(16):
            await get_tree().create_timer(t).timeout
            var index: int = randi() % nums.size()
            self.f_list.remove_file(Path.new([str(nums[index])]))
            nums.remove_at(index)
            index = randi() % nums.size()
            self.f_list.remove_file(Path.new([str(nums[index])]))
            nums.remove_at(index)
            index = randi() % nums.size()
            self.f_list.remove_file(Path.new([str(nums[index])]))
            nums.remove_at(index)
            index = randi() % nums.size()
            self.f_list.remove_file(Path.new([str(nums[index])]))
            nums.remove_at(index)
