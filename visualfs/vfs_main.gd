extends HSplitContainer

const FSManager = GVSClassLoader.gvm.filesystem.Manager
const FileList = GVSClassLoader.visualfs.FileList
const DragViewport = GVSClassLoader.visual.DragViewport.DragViewport
const Path = GVSClassLoader.gvm.filesystem.Path
const Narrator = GVSClassLoader.visualfs.narrator.Narrator

@onready var viewport: DragViewport = $Right/DragViewport
@onready var narrator: Narrator = $Left/Narrator
@onready var _p_cont: PanelContainer = $Left
@onready var _right_panel: PanelContainer = $Right


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var fs_man: FSManager = FSManager.new()
    self.narrator.setup(fs_man, self.viewport, self._right_panel)
    
    # Make sure the panel can't be resized to be smaller
    # than the button on that panel
    self._p_cont.custom_minimum_size.x = \
        self.narrator._next_button.get_minimum_size().x + 24
    self.narrator._next_button.minimum_size_changed.connect(
        func () -> void:
            self._p_cont.custom_minimum_size.x = \
                self.narrator._next_button.get_minimum_size().x + 24
    )
