extends RichTextLabel

var _commands: Array[Command]
var _header: RichTextLabel


class Command:
    var _text: String
    var _subcommands: Array[Command] = []
    var _fulfilled: bool = false
    
    func is_fulfilled() -> bool:
        if self._subcommands.is_empty():
            return self._fulfilled
        return GStreams.Stream(self._subcommands) \
                       .map(func (c: Command) -> bool: return c.is_fulfilled()) \
                       .all()
    
    func _init(text: String) -> void:
        self._text = text
    
    func set_fulfill(b: bool) -> void:
        self._fulfilled = b
    
    func change_text(text: String) -> void:
        self._text = text
    
    func add_command(c: Command) -> void:
        self._subcommands.push_back(c)
    
    func remove_command(index: int) -> void:
        self._subcommands.remove_at(index)


func setup(header: RichTextLabel) -> void:
    self._header = header


func get_command(index: int) -> Command:
    return self._commands[index]


func collapse() -> void:
    self.visible = false
    self._header.visible = false


func uncollapse() -> void:
    self.visible = true
    self._header.visible = true


func render() -> void:
    self.text = ""
    if not self._commands.is_empty():
        for com: Command in self._commands.slice(0, -1):
            self._render_helper(com)
            self.add_text("\n")
        self._render_helper(self._commands[-1])
        
        if GStreams.Stream(self._commands) \
                   .map(func (c: Command) -> bool: return c.is_fulfilled()) \
                   .all():
            self._header.add_theme_color_override("default_color", Color.GREEN)
        else:
            self._header.add_theme_color_override("default_color", Color.RED)
    else:
        self._header.add_theme_color_override("default_color", Color.GREEN)


func _render_helper(c: Command, depth: int = 0) -> void:
    var color: Color
    var prefix: String
    if c.is_fulfilled():
        color = Color.GREEN
        prefix = "✓ - "
    else:
        color = Color.RED
        prefix = "✕ - "
    
    self.push_color(color)
    self.add_text(
        "".join(GStreams.Repeat("    ").take(depth).as_array())
        + prefix + c._text
    )
    self.pop()
    
    if not c._subcommands.is_empty():
        for com: Command in c._subcommands.slice(0, -1):
            self._render_helper(com, depth + 1)
            self.add_text("\n")
        self._render_helper(c._subcommands[-1], depth + 1)
