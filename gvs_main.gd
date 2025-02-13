## This class is the root of everything going on.
## It manages a GVShell instance, which is the textual interface to the user,
## As well as a FSViewport instance, which is the graphical interface
## to the user.

extends HBoxContainer

const GVSClassLoader = preload("res://gvs_class_loader.gd")
const FSGraph_C = GVSClassLoader.visual.DragViewport.DragViewport
const FileTree_C = GVSClassLoader.visual.FileTree.FileTree
const DragViewport_C = GVSClassLoader.visual.DragViewport.DragViewport

## A reference to the child GVShell instance - the textual interface
## for the user.
@onready var GvShell = $GvShell
# This feels like very bad practice
@onready var prompt = $GvShell/ScrollContainer/VBoxContainer/Prompt
@onready var FsViewport = $Right/FsViewport
@onready var ViewportContainer = $Right/FsViewport/SubViewportContainer
@onready var NarratorToggle = $Right/Narrator/VBoxContainer/Toggle
@onready var NarratorNext = $Right/Narrator/VBoxContainer/Next
@onready var DragViewport: DragViewport_C  = $Right/DragViewport


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
        and self.FsViewport.get_global_rect().has_point(self.get_global_mouse_position())
        # Update this when there are other focus stealers around
        and focus_owner in [
            self.prompt,
            self.NarratorToggle,
            self.NarratorNext
        ]
    ):
        self.ViewportContainer._input(event)


## As the FSManager - the filesystem - is not a scene,
## it is created as a local variable and references to it are handed out
## to anyone who might need one (GVShell and FSViewport)
func _ready() -> void:
    var file_manager: FSManager = FSManager.new()
    
    var file_tree: FileTree_C = FileTree_C.make_new()
    self.DragViewport.add_to_scene(file_tree)
    file_tree.setup(file_manager)
    
    self.GvShell.setup(file_manager)
    $Right/Narrator.setup(file_manager, self.GvShell)
    
    $Right/FsViewport/SubViewportContainer/SubViewport/FSGraph.setup(file_manager)
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

    
    # Connect GVShell cwd changed to FSViewport cwd change
    #self.GvShell.cwd_changed.connect($Right/FsViewport/SubViewportContainer/SubViewport/FSGraph.change_cwd)
    # Connect GVShell previewing_path to FWViewport highlight path
    self.GvShell.previewing_path.connect($Right/FsViewport/SubViewportContainer/SubViewport/FSGraph.highlight_path) 
        
    $GvShell/ScrollContainer/VBoxContainer/Prompt.focus_released.connect(
        $Right/Narrator/VBoxContainer/Toggle.accept_focus
    )


# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta: float) -> void:
#     pass
