extends VBoxContainer

## Array of commands
var _commands: Array[Command]
## Title printed above instructions
@onready var _header: RichTextLabel = $Header
## RichTextLabel where instructions will be printed
@onready var _content: RichTextLabel = $Content


class Command:
    var _text: String
    var _subcommands: Array[Command] = []
    var _fulfilled: bool = false

    ## Returns whether or not this command has been completed or not.
    ## If a command has no subcommands, it is considered completed
    ## if it has been marked fulfilled through [code]set_fulfill[/code],
    ## and if it has subcommands it is considered fulfilled
    ## if all of its subcommands are fulfilled.[br][br]
    ##
    ## [param return]: true if the command was fulfilled, false otherwise.
    func is_fulfilled() -> bool:
        if self._subcommands.is_empty():
            return self._fulfilled
        return self._subcommands.all(
            func (c: Command) -> bool: return c.is_fulfilled()
        )

    ## Constructor for Command.[br][br]
    ##
    ## [param text]: text describing the instruction to be given.
    func _init(text: String) -> void:
        self._text = text

    func set_fulfill(b: bool) -> void:
        self._fulfilled = b

    func change_text(text: String) -> void:
        self._text = text

    func add_command(c: Command, index: int = -1) -> void:
        if index == -1:
            self._subcommands.push_back(c)
        else:
            self._subcommands.insert(index, c)

    func remove_command(index: int) -> void:
        self._subcommands.remove_at(index)

    func remove_command_ref(c: Command) -> void:
        var index: int = self._subcommands.find(c)
        if index < 0:
            for subc: Command in self._subcommands:
                subc.remove_command_ref(c)
        else:
            self._subcommands.remove_at(index)

    func get_command(index: int) -> Command:
        return self._subcommands[index]


func add_command(c: Command, index: int = -1) -> void:
    if index == -1:
        self._commands.push_back(c)
    else:
        self._commands.insert(index, c)


func remove_command(index: int) -> void:
    self._commands.remove_at(index)


func remove_command_ref(c: Command) -> void:
    for com: Command in self._commands:
        com.remove_command_ref(c)


func remove_all() -> void:
    self._commands.clear()


func get_command(index: int) -> Command:
    return self._commands[index]


func render() -> void:
    self._content.text = ""
    if not self._commands.is_empty():
        for com: Command in self._commands.slice(0, -1):
            self._render_helper(com)
            self._content.add_text("\n")
        self._render_helper(self._commands[-1])

        if self._commands.all(
            func (c: Command) -> bool: return c.is_fulfilled()
        ):
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
        prefix = "[✓] "
    else:
        color = Color.RED
        prefix = "[✕] "

    self._content.push_color(color)
    self._content.add_text(
        "".join(GStreams.Repeat("    ").take(depth).as_array())
        + prefix
    )
    self._content.pop()
    self._content.add_text(c._text)

    if not c._subcommands.is_empty():
        self._content.add_text("\n")
        for com: Command in c._subcommands.slice(0, -1):
            self._render_helper(com, depth + 1)
            self._content.add_text("\n")
        self._render_helper(c._subcommands[-1], depth + 1)
