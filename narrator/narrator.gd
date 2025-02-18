extends Control

const ClassLoader = preload("res://gvs_class_loader.gd")
const FSManager = ClassLoader.gvm.filesystem.Manager
const Shell = ClassLoader.gvm.Shell
const MathUtils = ClassLoader.shared.Math
const Checkpoint = ClassLoader.narrator.lesson.Checkpoint

const up_arrow = preload("res://narrator/assets/up.svg")
const down_arrow = preload("res://narrator/assets/down.svg")

var expanded: bool = true
var target_expanded: bool = true
var expanding_time: float = 0
@onready var min_size: float = $VBoxContainer/Toggle.size.y + 12
@onready var max_size: float = self.get_viewport_rect().end.y / 2
@onready var label: RichTextLabel = $VBoxContainer/RichTextLabel
@onready var next: Button = $VBoxContainer/Next
@onready var toggle: Button = $VBoxContainer/Toggle
var _fs_man: FSManager
var _shell: Shell
var current_checkpoint: Checkpoint


func setup(fs_man: FSManager, shell: Shell) -> void:
    self._fs_man = fs_man
    self._shell = shell
    self.load_checkpoint(
        load("res://narrator/lesson/navigation/introduction_0.gd").new(
            self._fs_man, self.label, self._shell, $VBoxContainer/Next
        )
    )


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass


func load_checkpoint(c: Checkpoint) -> void:
    # have to hold a reference so it's not deleted from memory while it waits lol
    self.current_checkpoint = c
    self.next.disabled = true
    c.start()
    c.completed.connect(self.load_checkpoint)
    

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if self.expanding_time > 0:
        self.expanding_time -= delta
        if self.target_expanded:
            self.custom_minimum_size.y = MathUtils.log_interp(
                self.min_size,
                self.max_size,
                1 - (self.expanding_time / 2)
            )
        else:
            self.custom_minimum_size.y = MathUtils.log_interp(
                self.max_size,
                self.min_size,
                1 - (self.expanding_time / 2)
            )
    elif self.target_expanded != self.expanded:
        self.expanded = self.target_expanded
        self.toggle.disabled = false
        if self.expanded:
            self.label.show()
            self.next.show()


func _on_button_pressed() -> void:
    self.toggle.disabled = true
    if self.expanded:
        self.label.hide()
        self.next.hide()
        self.toggle.icon = self.up_arrow
    else:
        self.toggle.icon = self.down_arrow
    
    self.expanding_time = 2
    self.target_expanded = not self.target_expanded
