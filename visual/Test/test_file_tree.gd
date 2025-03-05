extends Control

const FManager = GVSClassLoader.gvm.filesystem.Manager
const Path = GVSClassLoader.gvm.filesystem.Path
const FileTree = GVSClassLoader.visual.FileTree
const DragViewport = GVSClassLoader.visual.DragViewport.DragViewport
const TreeNode = GVSClassLoader.visual.file_nodes.TreeNode


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var fs_man := FManager.new()
    var ft := FileTree.make_new()
    fs_man.created_dir.connect(ft.create_node_dir)
    fs_man.removed_dir.connect(ft.remove_node)
    fs_man.created_file.connect(ft.create_node_file)
    fs_man.removed_file.connect(ft.remove_node)
    ($DragViewport as DragViewport).add_to_scene(ft)
    
    while true:
        fs_man.create_file(Path.new(["file0"]))
        await GVSGlobals.wait(2)
        fs_man.create_file(Path.new(["file1"]))
        await GVSGlobals.wait(2)
        fs_man.create_file(Path.new(["file2"]))
        await GVSGlobals.wait(2)
        fs_man.create_dir(Path.new(["dir0"]))
        await GVSGlobals.wait(2)
        fs_man.create_file(Path.new(["dir0", "file0"]))
        await GVSGlobals.wait(2)
        fs_man.create_file(Path.new(["dir0", "file1"]))
        await GVSGlobals.wait(2)
        fs_man.create_dir(Path.new(["dir1"]))
        await GVSGlobals.wait(2)
        fs_man.create_dir(Path.new(["dir2"]))
        await GVSGlobals.wait(2)
        fs_man.create_dir(Path.new(["dir1", "dir0"]))
        await GVSGlobals.wait(2)
        fs_man.create_dir(Path.new(["dir1", "dir1"]))
        await GVSGlobals.wait(2)
        fs_man.create_file(Path.new(["dir1", "dir1", "file0"]))
        await GVSGlobals.wait(2)
        
        fs_man.remove_file(Path.new(["file1"]))
        await GVSGlobals.wait(2)
        fs_man.remove_file(Path.new(["dir0", "file1"]))
        await GVSGlobals.wait(2)
        fs_man.remove_file(Path.new(["dir0", "file0"]))
        await GVSGlobals.wait(2)
        fs_man.remove_dir(Path.new(["dir1", "dir0"]))
        await GVSGlobals.wait(2)
        fs_man.remove_file(Path.new(["dir1", "dir1", "file0"]))
        await GVSGlobals.wait(2)
        fs_man.remove_dir(Path.new(["dir1", "dir1"]))
        await GVSGlobals.wait(2)
        fs_man.remove_dir(Path.new(["dir1"]))
        await GVSGlobals.wait(2)
        fs_man.remove_dir(Path.new(["dir2"]))
        await GVSGlobals.wait(2)
        fs_man.remove_dir(Path.new(["dir0"]))
        await GVSGlobals.wait(2)
        fs_man.remove_file(Path.new(["file0"]))
        await GVSGlobals.wait(2)
        fs_man.remove_file(Path.new(["file2"]))
        await GVSGlobals.wait(2)
