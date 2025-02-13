## This class is the root of everything going on.
## It manages a GVShell instance, which is the textual interface to the user,
## As well as a FSViewport instance, which is the graphical interface
## to the user
extends HBoxContainer

const ClassLoader = preload("res://gvs_class_loader.gd")
const FileTree = ClassLoader.visual.FileTree.FileTree
const DragViewport = ClassLoader.visual.DragViewport.DragViewport
const Shell = ClassLoader.gvm.Shell
const FSManager = ClassLoader.gvm.filesystem.Manager
const Path = ClassLoader.gvm.filesystem.Path

## A reference to the child GVShell instance - the textual interface
## for the user.
@onready var gvshell: Shell = $GvShell
# This feels like very bad practice
@onready var prompt = $GvShell/ScrollContainer/VBoxContainer/Prompt
@onready var NarratorToggle = $Right/Narrator/VBoxContainer/Toggle
@onready var NarratorNext = $Right/Narrator/VBoxContainer/Next
@onready var drag_viewport: DragViewport  = $Right/DragViewport


## It would be helpful to be able to forward user input to the
## FSViewport when the GVShell terminal (or anyone else!) has focus
## (specifically its text input component).
## This function takes input that is not handled by the GVShell
## (e.g. clicks on the FSViewport that is part of the Main scene)
## and sends them to the FSViewport.
##
## @param event: The event to forward to the FSViewport.
func _input(event: InputEvent) -> void:
    var focus_owner = self.get_viewport().gui_get_focus_owner()
    if (
        event is InputEventMouseButton
        and self.drag_viewport.get_global_rect().has_point(self.get_global_mouse_position())
        # Update this when there are other focus stealers around
        and focus_owner in [
            self.prompt,
            self.NarratorToggle,
            self.NarratorNext
        ]
    ):
        self.drag_viewport._input(event)


## As the FSManager - the filesystem - is not a scene,
## it is created as a local variable and references to it are handed out
## to anyone who might need one (GVShell and FSViewport)
func _ready() -> void:
    var file_manager: FSManager = FSManager.new()
    
    var file_tree: FileTree = FileTree.make_new()
    self.drag_viewport.add_to_scene(file_tree)
    file_tree.setup(file_manager)
    
    self.gvshell.setup(file_manager)
    $Right/Narrator.setup(file_manager, self.gvshell)
    self.gvshell.cwd_changed.connect(
        func (path, _old_path):
        self.drag_viewport.move_cam_to(file_tree.node_rel_pos_from_path(path))
    )
    self.gvshell.cwd_changed.connect(file_tree.change_cwd)
    self.gvshell.previewing_path.connect(file_tree.highlight_path)

    #test.create_dir(FSPath.new(["dir0"]))
    #test.create_dir(FSPath.new(["dir1"]))
    #test.create_dir(FSPath.new(["dir2"]))
    #test.create_dir(FSPath.new(["dir3"]))
    #test.create_dir(FSPath.new(["dir0", "0"]))
    #test.create_dir(FSPath.new(["dir0", "1"]))
    #test.create_dir(FSPath.new(["dir1", "0"]))
    #test.create_dir(FSPath.new(["dir1", "0"]))
    #test.create_dir(FSPath.new(["dir1", "1"]))
    #test.create_dir(FSPath.new(["dir1", "1", "0"]))
    #test.create_dir(FSPath.new(["dir1", "1", "1"]))

    $GvShell/ScrollContainer/VBoxContainer/Prompt.focus_released.connect(
        $Right/Narrator/VBoxContainer/Toggle.accept_focus
    )
