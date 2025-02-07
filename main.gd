## This class is the root of everything going on.
## It manages a GVShell instance, which is the textual interface to the user,
## As well as a FSViewport instance, which is the graphical interface
## to the user.

extends HBoxContainer

## A reference to the child GVShell instance - the textual interface
## for the user.
@onready var GVShell = $GvShell
# This feels like very bad practice
@onready var prompt = $GvShell/ScrollContainer/VBoxContainer/Prompt
@onready var ViewpointContainer = $FsViewport/SubViewportContainer

## A reference to the child FSViewport instance - the visual interface
## for the user.
@onready var FSViewport = $FsViewport


## It would be helpful to be able to forward user input to the
## FSViewport when the GVShell terminal has focus
## (specifically its text input component).
## This function takes input that is not handled by the GVShell
## (e.g. clicks on the FSViewport that is part of the Main scene)
## and sends them to the FSViewport.
##
## @param event: The event to forward to the FSViewport.
func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton and self.get_viewport().gui_get_focus_owner() == self.prompt:
        self.ViewpointContainer._input(event)


## As the FSManager - the filesystem - is not a scene,
## it is created as a local variable and references to it are handed out
## to anyone who might need one (GVShell and FSViewport)
func _ready() -> void:
    var test: FSManager = FSManager.new()
    $GvShell.setup(test)
    $FsViewport/SubViewportContainer/SubViewport/FSGraph.setup(test)
    test.create_dir(FSPath.new(["dir0"]))


# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta: float) -> void:
#     pass
