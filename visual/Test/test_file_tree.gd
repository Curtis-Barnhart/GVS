extends Control

const FManager = GVSClassLoader.gvm.filesystem.Manager
const Path = GVSClassLoader.gvm.filesystem.Path
const FileTree = GVSClassLoader.visual.FileTree2
const DragViewport = GVSClassLoader.visual.DragViewport.DragViewport


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var fs_man := FManager.new()
    var ft := FileTree.make_new()
    fs_man.created_dir.connect(ft.create_node)
    fs_man.removed_dir.connect(ft.remove_node)
    fs_man.created_file.connect(ft.create_node)
    fs_man.removed_file.connect(ft.remove_node)
    ($DragViewport as DragViewport).add_to_scene(ft)
    
    print("/file0")
    fs_man.create_file(Path.new(["file0"]))
    await GVSGlobals.wait(2)
    print("/file1")
    fs_man.create_file(Path.new(["file1"]))
    await GVSGlobals.wait(2)
    print("/file2")
    fs_man.create_file(Path.new(["file2"]))
    await GVSGlobals.wait(2)
    print("/dir0")
    fs_man.create_dir(Path.new(["dir0"]))
    await GVSGlobals.wait(2)
    print("/dir0/file0")
    fs_man.create_file(Path.new(["dir0", "file0"]))
    await GVSGlobals.wait(2)
    print("/dir0/file1")
    fs_man.create_file(Path.new(["dir0", "file1"]))
    await GVSGlobals.wait(2)
    print("/dir1")
    fs_man.create_dir(Path.new(["dir1"]))
    await GVSGlobals.wait(2)
    print("/dir2")
    fs_man.create_dir(Path.new(["dir2"]))
    await GVSGlobals.wait(2)
    print("/dir1/dir0")
    fs_man.create_dir(Path.new(["dir1", "dir0"]))
    await GVSGlobals.wait(2)
    print("/dir1/dir1")
    fs_man.create_dir(Path.new(["dir1", "dir1"]))
    await GVSGlobals.wait(2)
    print("/dir1/dir1/file0")
    fs_man.create_file(Path.new(["dir1", "dir1", "file0"]))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
