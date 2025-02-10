extends Checkpoint


func start() -> void:
    self.text_screen.text = Checkpoint.make_article([
        "What's a Tree Anyways?",
        [
            "To understand how to work within the terminal,",
            "you have to understand your [color=dark blue]file system[/color] first.",
            "The file system of your computer is where all your files are stored.",
        ],
        [
            "The file system is organized as a [color=dark blue]tree[/color],",
            "which means that, like a tree, it has [color=dark blue]branches[/color].",
            "On a tree, each branch can have [i]more[/i] branches,",
            "and [i]those[/i] branches can have branches, and so on.",
            "In the same way, the file system has [color=dark blue]directories[/color]",
            "(you may also know them by the name 'folders').",
        ],
        [
            "Directories are like the branches on a tree -",
            "they can contain [color=dark blue]leaves[/color]",
            "([color=dark blue]files[/color]) -",
            "but they can also contain [i]more directories[/i].",
            "This nested structure is helpful for organization -",
            "instead of memorizing every file you have by name,",
            "you can sort your files into directories that group them",
            "according to their use, and you can group [i]those[/i]",
            "directories inside other directories if you want",
            "to have further hierarchies of organization.",
        ]
    ])
    self.text_screen.scroll_to_line(0)
    self.next_button.pressed.connect(self.finished)
    self.next_button.disabled = false


func finished() -> void:
    self.completed.emit(
        load("res://narrator/lesson/navigation/mkdir_0.gd").new(
            self.fs_man, self.text_screen, self.shell, self.next_button
        )
    )
