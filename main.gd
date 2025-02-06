extends HBoxContainer

@onready var GVShell = $GvShell
@onready var prompt = $GvShell/ScrollContainer/VBoxContainer/Prompt
@onready var ViewpointContainer = $FsViewport/SubViewportContainer


# We want to forward the first click on the FsViewport
# (and actually to anyone else who wants it when we add more elements)
# because the input isn't going to FsViewport if FsViewport doesn't have focus,
# which happens on the first click while the prompt has focus
func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton and self.get_viewport().gui_get_focus_owner() == self.prompt:
        self.ViewpointContainer._input(event)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var test: FSManager = FSManager.new()
    $GvShell.setup(test)
    $FsViewport/SubViewportContainer/SubViewport/FSGraph.setup(test)
    test.create_dir(FSPath.new(["dir0"]))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
